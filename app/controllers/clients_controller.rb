class ClientsController < ApplicationController
  before_action :set_client, only: %i[show edit update destroy]

  def index
    @clients = Client.all
  end

  def show
    
  end

  def new
    @client = Client.new
  end

  def create
    command = SaveCommand.new(Client, client_params)
    @client, success = command_manager.execute(command)
    if success
      redirect_to @client, notice: "Клиент успешно создан!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    command = UpdateCommand.new(Client, @client.uuid, client_params)
    @client, success = command_manager.execute(command)
    if success
      redirect_to @client, notice: "Клиент успешно обновлён!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    command = DestroyCommand.new(Client, @client.uuid)
    
    command_manager.execute(command)
    redirect_to clients_path, notice: "Клиент удалён!"
  end

  def undo
    if command_manager.undo
      redirect_to clients_path, notice: "Отменено"
    else
      redirect_to clients_path, alert: "Нечего отменять"
    end
  end

  def redo
    if command_manager.redo
      redirect_to clients_path, notice: "Повторено"
    else
      redirect_to clients_path, alert: "Нечего повторять"
    end
  end

  private

  def set_client
    @client = Client.find_by(id: params[:id])
  end

  def client_params
    params.require(:client).permit(:first_name, :last_name, :patronymic, :email, :phone, :date_of_birth, :balance)
  end

  def command_manager
    @command_manager ||= CommandManager.new(Client, session.id)
  end
end