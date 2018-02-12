require_relative './model/model'

class App < Sinatra::Base

	enable :sessions
	include TodoDB

	def set_error(error_message)
		session[:error] = error_message
	end

	def get_error()
		error = session[:error]
		session[:error] = nil
		return error
	end

	get('/') do
		slim(:index)
	end

	get('/register') do
		slim(:register)
	end

	get('/error') do
		slim(:error)
	end

	get('/notes/create') do
		slim(:create_note)
	end

	get('/notes/:id/edit') do
		note_id = params[:id]
		note = get_note(note_id)
		user_id = session[:user_id] 
		if(user_id && note["user_id"] == user_id.to_i)
			slim(:edit_note, locals:{note:note})
		else
			redirect('/')
		end
		
	end

	get('/notes') do
		user_id = session[:user_id] 
		if user_id
			notes = list_notes(user_id)
			slim(:list_notes, locals:{notes:notes})
		else
			redirect('/')
		end
	end

	post('/register') do
		username = params["username"]
		password = params["password"]
		password_confirmation = params["confirm_password"]
		
		user = get_user(username)

		if user.nil?
			if password == password_confirmation
				create_user(username, password)
				redirect('/')
			else
				set_error("Passwords don't match")
				redirect('/error')
			end
		else
			set_error("Username already exists")
			redirect('/error')
		end	
	end
	
	
	post('/login') do
		username = params["username"]
		password = params["password"]
		
		user = get_user(username)

		if user.nil?
			set_error("Invalid Credentials")
			redirect('/error')
		end
		user_id = user["id"]
		password_digest = user["password_digest"]
		
		if BCrypt::Password.new(password_digest) == password
			session[:user_id] = user_id
			redirect('/notes')
		else
			set_error("Invalid Credentials")
			redirect('/error')
		end
	end

	post('/logout') do
		session.destroy
		redirect('/')
	end
	
	post('/notes/create') do
		user_id = session[:user_id]
		if user_id
			content = params["content"]
			create_note(user_id, content)
			redirect('/notes')
		else
			redirect('/')
		end
	end
	
	post('/notes/:id/delete') do
		user_id = session[:user_id].to_i
		if session[:user_id]
			note_id = params[:id]
			delete_note(user_id, note_id)
			redirect('/notes')
		else
			redirect('/')
		end
	end
	
	post('/notes/:id/update') do
		user_id = session[:user_id]
		if user_id
			note_id = params[:id]
			new_content = params["content"]
			update_note(user_id, note_id, new_content)
			redirect('/notes')
		else
			redirect('/')
		end
	end

end           
