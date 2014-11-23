require 'nokogiri'
require 'open-uri'
require 'crunchbase'
require 'fb_graph'

module Lowgo

  class << self

    def logos_for(options = {})
      @options = options
      set_vars && sources_hash
    end

    private

    def set_vars
      if @options[:url] && @options[:brand]
        @url = clean_url(@options[:url])
        @brand = @options[:brand]
      elsif @options[:url]
        @url = clean_url(@options[:url])
        @brand = brand_from_url
      elsif @options[:brand]
        @brand = @options[:brand]
        @url = clean_url(url_from_brand)
      end
    end

    def sources_hash
      c = { facebook: Sources::Facebook.all(@brand),
            crunchbase: Sources::Crunchbase.all(@brand) }
      @url ? c.merge!(dom: Sources::Dom.all(@url)) : c
    end

    def clean_url(url)
      return nil unless url.present?
      host = hostname_from_url(url.first(4) == 'http' ? url : "http://#{url}")
      "http://#{host}"
    end

    def hostname_from_url(url)
      URI.parse(url).hostname
    end

    def brand_from_url
      hostname_from_url(@url).split('.').last(2).first rescue nil
    end

    def url_from_brand
      Sources::Facebook.url_from_brand(@brand)
    end
  end

  module Sources

    module Dom

      class << self

        def all(url)
          @url = url
          @doc = Nokogiri::HTML(open(@url))
          absolute_url(candidate_image_url, @url)
        rescue StandardError => e
          puts "#{e.class}: #{e.message}"
        end

        private

        def candidate_image_url
          first_pass ? first_pass : second_pass
        end

        def first_pass
          URI.extract(@doc.to_s).
              select { |l| l[/\.(?:gif|png|jpe?g)\b/] }.
              select { |l| l[/logo/i] }.
              first
        end

        def second_pass
          strings = candidate_image_nodes.flat_map(&:text).map do |relative_path|
            absolute_url(relative_path, @url)
          end
          URI.extract(strings.join('')).first
        end

        def candidate_image_nodes
          candidate_xpath_strings.flat_map do |xpath|
            @doc.xpath(xpath)
          end.uniq
        end

        def candidate_dom_nodes
          candidate_css_selectors.flat_map do |selector|
            @doc.css(selector)
          end.uniq
        end

        def candidate_css_selectors
          ['#logo img', '[id*=logo] img', '.logo img', '[class*=logo] img', '[src*=logo]']
        end

        def candidate_xpath_strings
          ["descendant-or-self::img[contains(@src, 'logo')]/@src",
           "descendant-or-self::*[contains(@class, 'logo')]/descendant::img/@src",
           "descendant-or-self::*[contains(@id, 'logo')]/descendant::img/@src"]
        end

        def absolute_url(href, root)
          URI.parse(root).merge(URI.parse(href)).to_s rescue href
        end
      end
    end

    module Facebook

      class << self

        def all(brand)
          @brand = brand
          candidate_image_url rescue ''
        rescue StandardError => e
          puts "#{e.class}: #{e.message}"
        end

        def url_from_brand(brand)
          @brand = brand
          brand_page.website
        rescue StandardError => ex
          puts "#{ex.class}: #{ex.message}"
        end

        private

        def candidate_image_url
          brand_page.picture
        end

        def brand_page
          ::FbGraph::Page.fetch(@brand) rescue nil
        end
      end
    end

    module Crunchbase

      class << self

        def all(brand)
          ::Crunchbase::API.key = '4db9f69ad12121140fdb65d8e0ce338a'
          @brand = brand
          candidate_image_urls rescue []
        rescue StandardError => e
          puts "#{e.class}: #{e.message}"
        end

        private

        def candidate_image_urls
          crunchbase_search.image["available_sizes"].flat_map do |img|
            absolute_url(img.last, 'http://crunchbase.com')
          end
        end

        def crunchbase_search
          ::Crunchbase::Company.find(@brand)
        end

        def absolute_url(href, root)
          URI.parse(root).merge(URI.parse(href)).to_s
        end
      end
    end
  end
end
