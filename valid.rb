module Valid

	def self.errCheck (page)

		@errHash = {:username => 'Поле с именем пустое',
		:phone => 'Поле с телефоном пустое',
		:date_n_time => 'Поле с датой и временем пустое'}

		@error = errHash.select{|key| params[key] == ''}.values.join('|')

		if @error != ''
			return erb page
		end

	end

end