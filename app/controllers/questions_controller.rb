class QuestionsController < ApplicationController

  skip_before_filter :require_user , :only => [:new , :edit , :create , :update , :vote]
  after_filter :increment_total_views , :only => [:show]


  def index
    @questions = Question.paginate(:all , :page => params[:page] , :per_page => 10 , :order => 'created_at DESC')
  end

  def new
    @question = Question.new  
  end

  def create
    @question = Question.new(params[:question])
    @question.user = current_user
    if @question.save
      flash[:notice] = t('flash.notice.question.create.valid')
      redirect_to questions_path
    else
      flash[:notice] = t('flash.notice.question.create.invalid')
      render 'new'
    end
  end
  
  def show
    @question = Question.find(params[:id])
    @answers = @question.answers.all(:order => 'selected DESC')
  end

  def edit
    @question = current_user.questions.find(params[:id])
  end
  
  def update
    @question = current_user.questions.find(params[:id])
    if @question.update_attributes(params[:question])
      flash[:notice] = t('flash.notice.question.update.valid')
      redirect_to @question
    else
      flash[:notice] = t('flash.notice.question.update.invalid')
      render 'edit'
    end
  end

  def vote
    @question = Question.find(params[:id])
    @vote = @question.votes.find_by_user_id(current_user.id)
    if @vote
      if @vote.vote.to_s == params[:vote]
        flash[:notice] = t('flash.notice.question.vote.nochange')
      else
        @vote.update_attributes(:vote => params[:vote])
        flash[:notice] = t('flash.notice.question.vote.update')
      end
    else
      @vote = @question.votes.build(:user => current_user , :vote => params[:vote])
      if @vote.save
        flash[:notice] = t('flash.notice.question.vote.valid')
      else
        flash[:notice] = t('flash.notice.question.vote.invalid')
      end
    end
    respond_to do |format|
      format.js {}
    end  
  end

  def tag
    @questions = Question.tagged_with(params[:id] , :on => :tags).paginate(:page => params[:page] || 1, :per_page => 20)
    render 'index'
  end

  def unanswered
    @questions = Question.unanswered(params[:page])
    render 'index'
  end

  def hot
    @questions = Question.hot(params[:page])
    render 'index'
  end

  private
  
  def increment_total_views
    @question.increment!(:total_views)
  end

end
