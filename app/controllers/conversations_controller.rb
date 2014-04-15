class ConversationsController < ApplicationController
  before_action :set_family
  before_action :prepare_search_form, :only => [:index]
  before_action :only => [:index] do
    provide_relationships(@family)
  end

  def index
    @conversation = Conversation.new_conversation
    @permitted_conversations = current_person.all_permitted("conversation")
  end

  def create
    @conversation = Conversation.create(conversation_params)
    @conversation.permissions = @conversation.parse(params[:conversation][:parse_permission])
    @conversation.family_id = @family.id
    @conversation.person_id = current_person.id
    
    respond_to do |f|
      if @conversation.save
        f.js {render 'create', locals: {conversation: @conversation}}
        f.html {redirect_to :back}
      else
        @msg = "Please enter title and permissions."
        f.js {render 'create_failure', locals: {msge: @msg}}
      end 
    end

  end

  def destroy
    @conversation = Conversation.find(params[:conversation_id])
    respond_to do |f|
      if current_person == @conversation.owner
        @conversation.destroy
        f.html {redirect_to family_conversations_path}
        f.js {render 'destroy'}
      else
        @msg = "Sorry, you do not own this conversation."
        f.js {render 'destroy_failure', locals: {msge: @msg}}
      end
    end
  end

  private

  def prepare_search_form
    @conversations = Conversation.all_conversations
    @search = Conversation.search(params[:q])
    @all_found = @search.result
    @last_search = params[:q]
    @not_found = @conversations - @all_found
    @not_found_ids =  @not_found.collect do |conversation|
                        conversation.id
                      end
    if params[:show_all] != nil
      respond_to do |f|
        f.html {head :ok}
        f.js {render 'show_all'}    
      end
    elsif params[:q] != nil
      respond_to do |f|
        f.html {head :ok}
        f.js {render 'search_success', locals: {unfound: @not_found_ids}}
      end
    end
  end

  def conversation_params
    params.require(:conversation).permit(:title)
  end
end
