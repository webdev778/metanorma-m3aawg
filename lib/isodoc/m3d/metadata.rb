require "isodoc"

module IsoDoc
  module M3d
    # A {Converter} implementation that generates CSAND output, and a document
    # schema encapsulation of the document for validation
    class Metadata < IsoDoc::Metadata
      def initialize(lang, script, labels)
        super
        here = File.dirname(__FILE__)
        set(:logo_html,
            File.expand_path(File.join(here, "html", "m3-logo.png")))
        set(:logo_word,
            File.expand_path(File.join(here, "html", "logo.jpg")))
      end

      def title(isoxml, _out)
        main = isoxml&.at(ns("//bibdata/title[@language='en']"))&.text
        set(:doctitle, main)
      end

      def subtitle(_isoxml, _out)
        nil
      end

      def author(isoxml, _out)
        set(:tc, nil)
        tc = isoxml.at(ns("//bibdata/ext/editorialgroup/committee"))
        set(:tc, tc.text) if tc
      end

      def docid(isoxml, _out)
        docnumber = isoxml.at(ns("//bibdata/docidentifier"))
        set(:docnumber, docnumber&.text)
      end

      def status_abbr(status)
        case status
        when "working-draft" then "wd"
        when "committee-draft" then "cd"
        when "draft-standard" then "d"
        else
          ""
        end
      end

      def unpublished(status)
        !%w(published withdrawn).include? status.downcase
      end

      def version(isoxml, _out)
        super
        revdate = get[:revdate]
        set(:revdate_monthyear, monthyr(revdate))
      end

      MONTHS = {
        "01": "January",
        "02": "February",
        "03": "March",
        "04": "April",
        "05": "May",
        "06": "June",
        "07": "July",
        "08": "August",
        "09": "September",
        "10": "October",
        "11": "November",
        "12": "December",
      }.freeze

      def monthyr(isodate)
        m = /(?<yr>\d\d\d\d)-(?<mo>\d\d)/.match isodate
        return isodate unless m && m[:yr] && m[:mo]
        return "#{MONTHS[m[:mo].to_sym]} #{m[:yr]}"
      end
    end
  end
end
