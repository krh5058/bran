classdef evt < event.EventData
    properties
            trial % Trial count
            order % Current order
            section % Current section
            pres % Current presentation
            img % Current image matrix
            abort = 0;
    end
    
  methods
    function this = evt(data)
      try
          f = fieldnames(data);
          for i = 1:length(f)
              this.(f{i}) = data.(f{i});
          end
      catch ME
          throw(ME);
      end
    end
  end
    
end

