require 'httparty'

module Hydrogel
  class Curl
    class << self
      def delete(path, query)
        return true if query.blank?
        response = HTTParty.delete(url(path,'_query'), body: query.to_json)
        response.code == 200
      end

      def delete_index(index)
        HTTParty.delete(url(index))
      end

      def create_index(path, options = {})
        HTTParty.put(url(path), body: options.to_json).code
      end

      def add_alias(args)
        aliass(:add, args)
      end

      def remove_alias(args)
        aliass(:remove, args)
      end

      private

      def url(*parts)
        ([Hydrogel::Config.base_url] + parts).join('/')
      end

      def aliass(action, args)
        body = {}
        body[:actions] = args.map do |name, indexes|
          indexes.map { |index| { action => { index: index, alias: name } } }
        end.flatten
        response = HTTParty.post(url('_aliases'), body: body.to_json)
        response.code == 200
      end
    end
  end
end
