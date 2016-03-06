class MoviesParser < BaseParser

  def get_movies
    movies = []

    City::NAMES.each do |city_name|
      html = Nokogiri::HTML(open("http://cinespaco.com.br/em-cartaz/", "Cookie" => "sec_cidade=#{City::IDS[city_name]}; path=/"))

      html.css('#programacao tr').each do |tr|
        movie_id = tr.css('.filme_nome a')[0].attr('href').split('/').last.strip
        movie_name = tr.css('.filme_nome a')[0].text
        
        movie = {
          id: movie_id,
          name: movie_name,
          url: "#{@request.protocol}#{@request.host}:#{@request.port}#{api_v1_movie_path(movie_id, format: :json)}"
        }

        movie_test_flag = false

        movies.each do |movie_test|
          if movie_test[:id] == movie_id
            movie_test_flag = !movie_test_flag 
            break
          end
        end

        movies << movie unless movie_test_flag
      end
    end

    return movies
  end

  def get_movie(movie_id)
    html = Nokogiri::HTML(open("http://cinespaco.com.br/filme/#{movie_id}"))

    unless html.css('#capa a')[0]
      return nil
    else
      htmlTrailer = Nokogiri::HTML(open("http://cinespaco.com.br/_services/trailer.php?id=#{html.css('#capa a')[0].attr('href').split('?id=').last}"))

      movie = {
        id: movie_id,
        image: html.css('#capa img')[0].attr('src'),
        trailer: "#{@request.protocol.sub('//', '')}#{htmlTrailer.css('iframe')[0].attr('src').split('?rel=').first}",
        name: html.css('#titulo').text,
        original_name: html.css('#detalhes p')[0].text.split(':').last.strip,
        pg: html.css('.classificacao').text,
        sinopse: html.css('#detalhes p')[1].text.split(':').last.strip,
        cast: html.css('#detalhes p')[3].text.split(':').last.strip,
        director: html.css('#detalhes p')[2].text.split(':').last.strip,
        cities: []
      }

      City::NAMES.each do |city_name|
        htmlCity = Nokogiri::HTML(open("http://cinespaco.com.br/filme/#{movie_id}", "Cookie" => "sec_cidade=#{City::IDS[city_name]}"))

        if htmlCity.css('#info #programacao')[0]
          city = {
            id: City::IDS[city_name],
            name: city_name,
            url: "#{@request.protocol}#{@request.host}:#{@request.port}#{api_v1_city_path(City::IDS[city_name], format: :json)}",
            state: {
              uf: State::UFS[city_name],
              name: State::NAMES[city_name],
              url: "#{@request.protocol}#{@request.host}:#{@request.port}#{api_v1_state_path(State::UFS[city_name].downcase, format: :json)}",
            },
            movie_theaters: [{
              id: City::IDS[city_name],
              name: htmlCity.css('#cinema_info h2 a')[0].text,
              url: "#{@request.protocol}#{@request.host}:#{@request.port}#{api_v1_movie_theater_path(City::IDS[city_name], format: :json)}",
              sessions: []
            }]
          }

          htmlCity.css('#info #programacao')[0].css('tr').each do |tr|
            session_room = nil
            session_imax = false
            session_vip = false

            if tr.css('.imax')[0]
              session_room = 'imax'
              session_imax = true
            elsif tr.css('.sala')[0].text.downcase.include?('vip')
              session_room = tr.css('.sala')[0].text.split(' ')[1].strip
              session_vip = true
            else
              session_room = tr.css('.sala')[0].text.split(' ').last.strip
            end

            session_subtitled = tr.css('.atributos')[0].text.downcase.include?('leg') ? true : false
            session_dubbed = tr.css('.atributos').text.downcase.include?('nac') ? true : false
            session_dubbed = tr.css('.atributos').text.downcase.include?('dub') ? true : false unless session_dubbed
            session_hours = tr.css('.horarios')[0].text.split('-').map(&:strip)
            session_3d = tr.css('.atributos')[0].text.downcase.include?('3d') ? true : false

            session = {
              room: session_room,
              subtitled: session_subtitled,
              dubbed: session_dubbed,
              '3d': session_3d,
              imax: session_imax,
              vip: session_vip,
              hours: session_hours
            }

            city[:movie_theaters][0][:sessions] << session
          end

          movie[:cities] << city
        end
      end

      return movie
    end

  end

end