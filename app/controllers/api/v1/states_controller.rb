module Api
  module V1
    class StatesController < BaseController
      skip_before_action :set_resource

      def index
        @states = @parser.get_states
      end

      def show
        state = @parser.get_state(params[:id])

        unless state
          @errors = {
            state: 'State doesn\'t exists'
          }

          respond_to do |format|
            format.json { render :error }
          end
        else
          @state = state
        end
      end

      private

        def state_params
          params.require(:state)
        end
        
    end
  end
end