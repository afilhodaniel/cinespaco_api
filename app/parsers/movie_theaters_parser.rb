class MovieTheatersParser < BaseParser

  def get_movie_theaters
    return parse_movie_theaters
  end

  def get_movie_theater(movie_theater_id)
    movie_theater = nil

    parse_movie_theaters.each do |movie_theater_test|
      if movie_theater_test[:id].to_s == movie_theater_id
        movie_theater = movie_theater_test
        break
      end
    end

    return movie_theater
  end

  private

    def parse_movie_theaters
      html = Nokogiri::HTML(open("http://cinespaco.com.br/_services/cidades.php"))

      movie_theaters = []

      html.css('ul li').each do |li|
        city_name = li.css('a')[0].text
        city_id = City::IDS[city_name]
        state_uf = State::UFS[city_name]
        state_name = State::NAMES[city_name]

        htmlMovieTheater = Nokogiri::HTML(open("http://cinespaco.com.br/em-cartaz/", "Cookie" => "sec_cidade=#{city_id}; path=/"))
        
        movie_theater_id = city_id
        movie_theater_name = htmlMovieTheater.css('#cinema_info h2 a')[0].text

        movie_theater = {
          id: movie_theater_id,
          name: movie_theater_name,
          url: "#{@request.protocol}#{@request.host}:#{@request.port}#{api_v1_movie_theater_path(movie_theater_id, format: :json)}",
          city: {
            id: city_id,
            name: city_name,
            url: "#{@request.protocol}#{@request.host}:#{@request.port}#{api_v1_city_path(city_id, format: :json)}",
            state: {
              uf: state_uf,
              name: state_name,
              url: "#{@request.protocol}#{@request.host}:#{@request.port}#{api_v1_state_path(state_uf.downcase, format: :json)}"
            }
          }
        }

        movie_theaters << movie_theater
      end

      return movie_theaters
    end

end