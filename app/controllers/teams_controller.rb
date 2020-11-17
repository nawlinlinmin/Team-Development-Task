class TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team, only: %i[show edit update destroy leader_change]
  before_action :team_edit, only: [:edit]


  def index
    @teams = Team.all
  end

  def show
    @working_team = @team
    change_keep_team(current_user, @team)
  end

  def new
    @team = Team.new
  end

  def edit
  end

  def create
    @team = Team.new(team_params)
    @team.owner = current_user
    if @team.save
      @team.invite_member(@team.owner)
      redirect_to @team, notice: 'チーム作成に成功しました！'
    else
      flash.now[:error] = '保存に失敗しました、、'
      render :new
    end
  end

  def update
    if @team.update(team_params)
      redirect_to @team, notice: 'チーム更新に成功しました！'
    else
      flash.now[:error] = '保存に失敗しました、、'
      render :edit
    end
  end

  def destroy
    @team.destroy
    redirect_to teams_url, notice: 'チーム削除に成功しました！'
  end

  def dashboard
    @team = current_user.keep_team_id ? Team.find(current_user.keep_team_id) : current_user.teams.first
  end

  def leader_change
    @team.owner_id = params[:owner_id]
    if @team.save
      redirect_to team_url(params[:id]), notice: '新リーダーの任命を行いました！'
      ChangeLeaderMailer.appointment_mail(@team.owner.email, @team.name).deliver
    else
      redirect_to team_url(params[:id]), notice: '新リーダーの任命に失敗しました・・・'
    end
  end

  private

  def set_team
    @team = Team.friendly.find(params[:id])
  end

  def team_params
    params.fetch(:team, {}).permit %i[name icon icon_cache owner_id keep_team_id]
  end

  def team_edit
    unless @team.isOwned?(current_user)
      redirect_to @team, notice: 'オーナーのみ編集できます'
    end
  end
end
