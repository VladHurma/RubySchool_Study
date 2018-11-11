module Valid

	def errChoose

		error = ''

		errHash = {:username => 'Поле с именем пустое',
		:phone => 'Поле с телефоном пустое',
		:date_n_time => 'Поле с датой и временем пустое'}

		error = errHash.select{|key| params[key] == ''}.values.join('|')

		return error

	end

	def errCheck(error, page)
		if error != ''
			return erb page
		end
	end
end