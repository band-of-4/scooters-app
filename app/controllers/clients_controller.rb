# class ClientsController < ApplicationController
#   before_action :set_client, only: %i[show edit update destroy]

#   def index
#     @clients = Client.all
#   end

#   def show
#   end

#   def new
#     @client = Client.new
#   end

#   def create
#     @client = Client.new(client_params)

#     if @client.save
#       redirect_to @client, notice: "Клиент успешно создан!"
#     else
#       render :new, status: :unprocessable_entity
#     end
#   end

#   def edit
#   end

#   def update
#     if @client.update(client_params)
#       redirect_to @client, notice: "Клиент успешно обновлён!"
#     else
#       render :edit, status: :unprocessable_entity
#     end
#   end

#   def destroy
#     @client.destroy
#     redirect_to clients_path, notice: "Клиент удалён!"
#   end

#   private

#   def set_client
#     @client = Client.find(params[:id])
#   end

#   def client_params
#     params.require(:client).permit(:first_name, :last_name, :patronymic, :email, :phone, :date_of_birth, :balance)
#   end
# end


class ClientsController < ApplicationController
  before_action :set_client, only: %i[show edit update destroy]

  def index
    @clients = clients_repo.all
  end

  def show
  end

  def new
    @client = clients_repo.build(total_spent: "0", total_rentals_count: "0")
  end

  def create
    @client = clients_repo.create(client_params)

    if @client
      redirect_to clients_path, notice: "Клиент успешно создан!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if clients_repo.update(params[:id], client_params)
      redirect_to client_path(params[:id]), notice: "Клиент успешно обновлен!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    clients_repo.destroy(params[:id])
    redirect_to clients_path, notice: "Клиент удален!"
  end

  private

  def client_params
    params.require(:client).permit(:first_name, :last_name, :patronymic, :email, :phone, :date_of_birth, :balance)
  end


  def set_client
    @client = clients_repo.find(params[:id])
  end

  def clients_repo
    @clients_repo ||= ClientsRepository.new
  end
end