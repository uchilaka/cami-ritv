# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :omniauthable
  devise :database_authenticatable, :registerable, :rememberable, :validatable, :recoverable,
         :confirmable, :timeoutable, :lockable, :trackable
end
