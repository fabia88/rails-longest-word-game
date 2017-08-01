class LongestWordController < ApplicationController
  def game
    @grid = Array.new(rand(5..10)) { ('A'..'Z').to_a.sample }.join(" ")
    @start_time = Time.new
  end

  def score
    @grid = params[:grid].split(" ")
    @start_time = Time.parse(params[:start_time])
    @end_time = Time.now
    @attempt = params[:attempt]
    @result = run_game(@attempt, @grid, @start_time, @end_time)
  end

private

  def calculate_score(attempt, time)
    time > 60.0 ? 0 : attempt.size * (1.0 - time / 60.0)
  end

  def message_generator(attempt, grid, translation, score, time)
    grid_downcase = grid.map { |x| x.downcase }
    check = attempt.chars.map do |char|
      if grid_downcase.include? char
        grid_downcase.delete(char)
        true
      else
        false
      end
    end
    if check.include? false
      [0, "not in the grid"]
    elsif attempt == translation
      [0, "not an english word"]
    else
      [calculate_score(attempt, time), "well done"]
    end
  end

  def run_game(attempt, grid, start_time, end_time)
    url = "https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=7c71c1b2-2454-40c8-b74c-343f6b111992&input=#{@attempt}"
    @translation = JSON.parse(open(url).read)
    @translation = @translation["outputs"][0]["output"]
    @time = end_time - start_time
    @score = 0
    @result_mes = message_generator(attempt, grid, @translation, @score, @time)
    @score = @result_mes[0]
    @message = @result_mes[1]
    @translation = nil if @score.zero?
    {
      translation: @translation,
      time: @time,
      score: @score,
      message: @message
    }
  end
end
