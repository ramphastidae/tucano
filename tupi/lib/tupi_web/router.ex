defmodule TupiWeb.Router do
  use TupiWeb, :router

  alias Tupi.Guardian

  if Mix.env == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end

  pipeline :api do
    plug :accepts, ["json", "json_api"]
  end

  pipeline :jwt_authenticated do
    plug Guardian.AuthPipeline
    plug Tupi.HeaderPlug
  end

  pipeline :json_api_spec do
    plug JSONAPI.EnsureSpec
    plug JSONAPI.ResponseContentType
    plug JSONAPI.UnderscoreParameters
  end

  pipeline :json_api_spec_bulk do
    plug JSONAPI.ContentTypeNegotiation
    plug JSONAPI.IdRequired
    plug JSONAPI.ResponseContentType
    plug JSONAPI.UnderscoreParameters
  end

  pipeline :tender_scope do
    # Should ensure
    #plug Tupi.HeaderPlug
    plug Tupi.ContestPlug
  end

  scope "/", TupiWeb do
    get "/", PageController, :index
  end

  scope "/api", TupiWeb do
    pipe_through :api

    scope "/auth" do
      post "/sign_in", AuthController, :sign_in

      resources "/passwords", PasswordController, only: [:create, :update]
    end

    scope "/v1" do
      pipe_through :jwt_authenticated
      pipe_through :json_api_spec

      resources "/managers", ManagerController, except: [:new, :edit]
      resources "/users", UserController, only: [:index, :show]
      resources "/contests", ContestController, only: [:index, :create, :show, :update]
    end

    scope "/v1" do
      pipe_through :jwt_authenticated
      pipe_through :json_api_spec
      pipe_through :tender_scope

      resources "/contests", ContestController, only: [:delete]
      resources "/applicants", ApplicantController, except: [:new, :edit] do
        resources "/incoherences", IncoherenceController, only: [:index, :show, :create, :delete]
        resources "/applications", ApplicationController, only: [:index]
      end
      resources "/incoherences", IncoherenceController, only: [:index, :update]
      resources "/settings", SettingController, only: [:index]
      resources "/subjects", SubjectController, except: [:new, :edit, :delete]
      resources "/results", ResultController, only: [:index]
      resources "/unplaced", UnplacedController, only: [:index]
      resources "/unmediated", UnmediatedController, only: [:index]

      get "/applicants/:id/results", ApplicantController, :results
      get "/contests/:id/applicant", ContestController, :applicant
    end

    scope "/v1" do
      pipe_through :jwt_authenticated
      pipe_through :tender_scope

      post "/contests/:id/mediator", ContestController, :mediator
    end

    #scope "/v1" do
    #  pipe_through :jwt_authenticated
    #  pipe_through :json_api_spec_bulk

    #  resources "/applicants", ApplicantController, only: [:create]
    #end
  end
end
