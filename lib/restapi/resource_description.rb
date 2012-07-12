module Restapi
  
  # Resource description
  # 
  # version - api version (1)
  # description
  # path - relative path (/api/articles)
  # methods - array of keys to Restapi.method_descriptions (array of Restapi::MethodDescription)
  # name - human readable alias of resource (Articles)
  # id - resouce name
  class ResourceDescription
    
    attr_reader :controller, :_short_description, :_full_description, :_methods, :_id,
      :_path, :_version, :_name, :_params_ordered, :_parent
    
    def initialize(controller, resource_name, &block)
      @_methods = []
      @_params_ordered = []

      @controller = controller
      @_id = resource_name
      @_version = nil 
      @_name = @_id.humanize
      @_full_description = ""
      @_short_description = ""
      @_path = ""
      @_parent = Restapi.get_resource_description(controller.superclass)
      
      block.arity < 1 ? instance_eval(&block) : block.call(self) if block_given?
    end

    def param(param_name, *args, &block)
      param_description = Restapi::ParamDescription.new(param_name, *args, &block)
      @_params_ordered << param_description
    end
    
    def path(path); @_path = path; end
    
    def version(version); @_version = version; end

    def _version
      @_version || @_parent.try(:_version)
    end
    
    def name(name); @_name = name; end
    
    def short(short); @_short_description = short; end
    alias :short_description :short
    
    def desc(description)
      description ||= ''
      @_full_description = Restapi.markup_to_html(description)
    end
    alias :description :desc
    alias :full_description :desc
    
    # add description of resource method
    def add_method(mapi_key)
      @_methods << mapi_key
      @_methods.uniq!
    end
    
    def doc_url
      Restapi.full_url(@_id)
    end

    def api_url; "#{Restapi.configuration.api_base_url}#{@_path}"; end
    
    def to_json(method_name = nil)

      _methods = if method_name.blank?
        @_methods.collect { |key| Restapi.method_descriptions[key].to_json }
      else
        [Restapi.method_descriptions[Restapi.construct_method_key(@_id, method_name)].to_json]
      end

      {
        :doc_url => doc_url,
        :api_url => api_url,
        :name => @_name,
        :short_description => @_short_description,
        :full_description => @_full_description,
        :version => _version,
        :methods => _methods
      }
    end
  end
end
