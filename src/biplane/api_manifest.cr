module Biplane
  # The `ApiManifest` class fetches an entire API structure for diffing against a `ConfigManifest`.
  # It works in a lazy-ish manner, fetching resources only upon request (even though it will fetch
  # *all* of the resources requested at once)
  class ApiManifest
    def initialize(@client : KongClient)
      @apis = ChildCollection.new("name", [] of Api)
      @consumers = ChildCollection.new("username", [] of Consumer)
    end

    def apis
      return @apis unless @apis.empty?
      apis = add_client @client.apis

      @apis = ChildCollection.new("name", apis)
    end

    def consumers
      return @consumers unless @consumers.empty?

      consumers = add_client @client.consumers
      # associate credentials which require knowledge of the plugins
      consumers.each &.cache_credentials(plugins)

      @consumers = ChildCollection.new("username", consumers)
    end

    def plugins
      apis.map(&.plugins.collection).flatten.uniq(&.name)
    end

    def serialize
      {
        "apis":      apis.serialize,
        "consumers": consumers.serialize,
      }
    end

    def ==(config : ConfigManifest)
      apis == config.apis &&
        consumers == config.consumers
    end

    def diff(config : ConfigManifest)
      {
        "apis":      apis.diff(config.apis),
        "consumers": consumers.diff(config.consumers),
      }.reject { |k, v| v.nil? }
    end

    private def add_client(items)
      items.map { |item| item.client = @client; item }
    end
  end
end
