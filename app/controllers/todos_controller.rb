class TodosController < ApplicationController
  # Callbacks
  before_action :check_permissions
  before_action :authorize_resource!

  def index
    render json: todos
  end

  def show
    render json: todo
  end

  def create
    create_todo = Todo.new(todo_params)

    if create_todo.save
      render json: create_todo, status: :created
    else
      render_errors(create_todo)
    end
  end

  def update
    if todo.update(todo_params)
      render json: todo
    else
      render_errors(todo)
    end
  end

  def destroy
    if todo.destroy
      render json: todo
    else
      render_errors(todo)
    end
  end

  private

  def todos
    return @todos if defined?(@todos)
    @todos = Todo.includes(:user).all
  end

  def todo
    return @todo if defined?(@todo)
    @todo = Todo.find(params[:id])
  end

  def todo_params
    params
        .require(:todo).permit(:text, :done)
        .merge(user_id: current_user.id)
  end

  def check_permissions
    return unless action_name.in? %w(create update destroy)
    authentication_required!

    case action_name.to_sym
    when :create
      authorize! action_name.to_sym, Todo
    when :update, :destroy
      authorize! action_name.to_sym, todo
    end
  end
end
