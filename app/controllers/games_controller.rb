require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = (0...8).map { ('a'..'z').to_a.sample }
    session[:letters] = @letters
  end

  def score
    @letters = session[:letters]
    @word = params[:try]
    @valid = @word.split(//).all? do |lettre|
      @letters.delete_at(@letters.index(lettre)) if @letters.include? lettre
    end
    @english = api_test(@word)
    compute_score(@word)
  end
end

def api_test(attempt)
  url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
  word_try = open(url).read
  response = JSON.parse(word_try)
  response['found']
end

def user_score(number_letter)
  100 + number_letter.to_i
end

def compute_score(attempt)
  if @english == false && @valid == true
    @score = { score: 0, message: "doesn't seem to be an english word..." }
  elsif @valid == false && @english == true
    @score = { score: 0, message: "can't be built out of" }
  else
    @score = { score: user_score(@word.length), message: "is a valid English word !" }
  end
end
