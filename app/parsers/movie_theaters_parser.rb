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

    if movie_theater
      html = Nokogiri::HTML(open("http://cinespaco.com.br/em-cartaz/", "Cookie" => "sec_cidade=#{movie_theater_id}; path=/"))

      from = html.css('#cinema_programacao h1').text.split('de')[1].split('a')[0].strip
      to = html.css('#cinema_programacao h1').text.split('de')[1].split('a')[1].strip

      weeks = [{
        from: from,
        to: to,
        sessions: []
      }]

      html.css('#programacao tr').each do |tr|
        room = tr.css('.sala')[0] ? tr.css('.sala').text.split(' ')[1].strip : tr.css('.imax')[0].text
        movie_id = tr.css('.filme_nome a')[0].attr('href').split('/').last
        movie_name = tr.css('.filme_nome')[0].text
        movie_pg = tr.css('.classificacao div')[0].text
        movie_dubbed = tr.css('.atributos').text.downcase.include?('nac') ? true : false
        movie_dubbed = tr.css('.atributos').text.downcase.include?('dub') ? true : false unless movie_dubbed
        movie_subtitled = tr.css('.atributos').text.downcase.include?('leg') ? true : false
        i3d = tr.css('.atributos').text.downcase.include?('3d') ? true : false
        imax = tr.css('.imax')[0] ? true : false
        vip = false
        vip = true if tr.css('.sala')[0] and tr.css('.sala')[0].text.downcase.include?('vip')
        hours = tr.css('.horarios').text.split('-').map(&:strip)


        session = {
          room: room,
          movie: {
            id: movie_id,
            name: movie_name,
            url: "#{@request.protocol}#{@request.host}:#{@request.port}#{api_v1_movie_path(movie_id, format: :json)}",
            pg: movie_pg,
            subtitled: movie_subtitled,
            dubbed: movie_dubbed
          },
          '3d': i3d,
          imax: imax,
          vip: vip,
          hours: hours
        }

        weeks[0][:sessions] << session
      end

      prices = []

      

      movie_theater[:weeks] = weeks
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