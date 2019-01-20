module EsmDiag
  module ActionHelpers
    def self.start previous_pipelines, options
      action_name = caller_locations(1,1)[0].label
      current_pipelines = []
      previous_pipelines.each do |pipeline|
        current_pipelines << [ :active, pipeline ]
      end
      # 如果该action仅跟随之前的若干actions，那么也只改动这些pipelines。
      if options[:follow]
        followed_actions = options[:follow].class == Array ? options[:follow] : [ options[:follow] ]
        current_pipelines.each do |status_pipeline|
          next if status_pipeline.last.empty?
          last_action = status_pipeline.last.split('.').last
          if followed_actions.select { |x| last_action =~ /#{x}/ }.empty?
            status_pipeline[0] = :inactive
          end
        end
      end
      # 如果该action从之前pipelines上detour，那么它不会覆盖之前的pipelines。
      if options[:detour]
        for i in 0..current_pipelines.size-1
          next if current_pipelines[i].first == :inactive
          # 复制一个新的pipeline。
          current_pipelines << [ :active, current_pipelines[i].last.clone ]
          current_pipelines[i][0] = :inactive
        end
      end
      # 清空之前的pipeline（这一步需要再考虑一下）。
      previous_pipelines.clear
      current_pipelines
    end

    def self.create_file_name comp, var, tag, pipeline = nil
      if tag == :fixed
        "#{ConfigManager.model_info[comp][:id]}.#{ConfigManager.case_info.id}.#{var}.nc"
      else
        "#{ConfigManager.model_info[comp][:id]}.#{ConfigManager.case_info.id}.#{var}.#{tag}#{pipeline}.#{ConfigManager.date.start}:#{ConfigManager.date.end}.nc"
      end
    end
  end
end
