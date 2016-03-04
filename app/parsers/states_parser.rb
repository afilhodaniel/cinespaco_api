class StatesParser < BaseParser

  def get_states
    return parse_states
  end

  def get_state(state_uf)
    state = nil

    parse_states.each do |state_test|
      if state_test[:uf].downcase == state_uf
        state = state_test
        break
      end
    end

    return state
  end

  private

    def parse_states
      html = Nokogiri::HTML(open("http://cinespaco.com.br/_services/cidades.php"))

      states = []

      html.css('ul li').each do |li|
        city_name = li.css('a')[0].text
        state_uf = State::UFS[city_name]
        state_name = State::NAMES[city_name]

        state = {
          uf: state_uf,
          name: state_name,
          url: "#{@request.protocol}#{@request.host}:#{@request.port}#{api_v1_state_path(state_uf.downcase, format: :json)}",
          cities: []
        }

        states << state unless states.include?(state)
      end

      states.each do |state|
        html.css('ul li').each do |li|
          city_name = li.css('a')[0].text
          city_id = City::IDS[city_name]
          state_uf = State::UFS[city_name]

          if state[:uf] == state_uf
            city = {
              id: city_id,
              name: city_name,
              url: "#{@request.protocol}#{@request.host}:#{@request.port}#{api_v1_city_path(city_id, format: :json)}",
            }

            state[:cities] << city
          end
        end
      end

      return states
    end

end