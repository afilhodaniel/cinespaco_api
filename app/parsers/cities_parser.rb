class CitiesParser < BaseParser

  def get_cities
    html = Nokogiri::HTML(open("http://cinespaco.com.br/_services/cidades.php"))

    cities = []

    html.css('ul li').each do |li|
      city_name = li.css('a')[0].text
      city_id = City::IDS[city_name]
      state_uf = State::UFS[city_name]
      state_name = State::NAMES[city_name]

      city = {
        id: city_id,
        name: city_name,
        url: "#{@request.protocol}#{@request.host}:#{@request.port}#{api_v1_city_path(city_id, format: :json)}",
        state: {
          uf: state_uf,
          name: state_name,
          url: "#{@request.protocol}#{@request.host}:#{@request.port}#{api_v1_state_path(state_uf.downcase, format: :json)}"
        },
        movie_theaters: []
      }

      htmlMovieTheater = Nokogiri::HTML(open("http://cinespaco.com.br/em-cartaz/", "Cookie" => "sec_cidade=#{city_id}; path=/"))

      movie_theater_id = city_id
      movie_theater_name = htmlMovieTheater.css('#cinema_info h2 a')[0].text

      movie_theater = {
        id: movie_theater_id,
        name: movie_theater_name,
        url: "#{@request.protocol}#{@request.host}:#{@request.port}#{api_v1_movie_theater_path(movie_theater_id, format: :json)}"
      }

      city[:movie_theaters] << movie_theater

      cities << city
    end

    return cities
  end

  def get_city(city_id)
    html = Nokogiri::HTML(open("http://cinespaco.com.br/em-cartaz/", "Cookie" => "sec_cidade=#{city_id}; path=/"))

    city = nil

    if html.css('#cinema_info')[0] != nil
      city_name = html.css('#cinema_info h1')[0].text
      state_uf = State::UFS[city_name]
      state_name = State::NAMES[city_name]
      movie_theater_id = city_id
      movie_theater_name = html.css('#cinema_info h2 a')[0].text

      city = {
        id: city_id,
        name: city_name,
        url: "#{@request.protocol}#{@request.host}:#{@request.port}#{api_v1_city_path(city_id, format: :json)}",
        state: {
          uf: state_uf,
          name: state_name,
          url: "#{@request.protocol}#{@request.host}:#{@request.port}#{api_v1_state_path(state_uf.downcase, format: :json)}"
        },
        movie_theaters: [{
          id: movie_theater_id,
          name: movie_theater_name,
          url: "#{@request.protocol}#{@request.host}:#{@request.port}#{api_v1_movie_theater_path(movie_theater_id, format: :json)}"
        }]
      }
    end

    return city
  end

end