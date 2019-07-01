defmodule TupiWeb.SubjectControllerTest do
  use TupiWeb.ConnCase

  alias Tupi.Accounts

  setup do
    {:ok, api_authenticate()}
  end

  describe "List all Subjects" do
    test "GET /subjects with valid manager", %{conn: conn, user: user} do
      Accounts.promote_user(user, :manager)
      contest_update(user)
      create_subject_strategy(:subject)

      conn =
        conn
        |> put_req_header("accept", "application/vnd.api+json")
        |> get(Routes.subject_path(conn, :index))
        |> doc()

      assert json_response(conn, 200)["data"] != []
      assert Bodyguard.permit(Accounts, :list_subjects, user)
    end

    test "GET /subjects with invalid manager", %{conn: conn, user: user} do
      create_subject_strategy(:subject)

      conn =
        conn
        |> put_req_header("accept", "application/vnd.api+json")
        |> get(Routes.subject_path(conn, :index))
        |> plug_doc(module: TupiWeb.SubjectController, action: :index)
        |> doc()

      assert json_response(conn, 404)["errors"] != []
      assert Bodyguard.permit(Accounts, :list_subjects, user) == {:error, :unauthorized}
    end
  end

  describe "Create Subject" do
    test "POST /subjects with valid manager", %{conn: conn, user: user} do
      Accounts.promote_user(user, :manager)
      contest_update(user)
      contest_update_before_begin()
      subject_in = create_subject_strategy(:subject)
      subject = build(:subject)
      timetable = subject.timetables |> List.first
      conflict = subject.conflicts |> List.first

      struct = %{
        data: %{
          attributes: %{
            code: subject.code,
            name: subject.name,
            openings: subject.openings,
            setting_id: subject_in.setting_id,
            timetables: [%{begin: timetable.begin, 
              end: timetable.end,
              weekday: timetable.weekday}],
            conflicts: [%{subject_code: conflict.subject_code}]
          },
          type: "subjects"
        }
      }

      conn =
        conn
        |> json_api_headers()
        |> post(Routes.subject_path(conn, :create), struct)
        |> doc()

      assert Bodyguard.permit(Accounts, :create_subject, user)
      assert json_response(conn, 201)["data"]["attributes"] != %{}
    end

    test "POST /subjects with valid manager, after begin", %{conn: conn, user: user} do
      Accounts.promote_user(user, :manager)
      contest_update(user)
      subject_in = create_subject_strategy(:subject)
      subject = build(:subject)
      timetable = subject.timetables |> List.first
      conflict = subject.conflicts |> List.first

      struct = %{
        data: %{
          attributes: %{
            code: subject.code,
            name: subject.name,
            openings: subject.openings,
            setting_id: subject_in.setting_id,
            timetables: [%{begin: timetable.begin, 
              end: timetable.end,
              weekday: timetable.weekday}],
            conflicts: [%{subject_code: conflict.subject_code}]
          },
          type: "subjects"
        }
      }

      conn =
        conn
        |> json_api_headers()
        |> post(Routes.subject_path(conn, :create), struct)
        |> doc()

      assert Bodyguard.permit(Accounts, :create_subject, user)
      assert json_response(conn, 401)["errors"] != []
    end

    test "POST /subjects with invalid manager", %{conn: conn, user: user} do
      subject_in = create_subject_strategy(:subject)
      subject = build(:subject)
      timetable = subject.timetables |> List.first

      struct = %{
        data: %{
          attributes: %{
            code: subject.code,
            name: subject.name,
            openings: subject.openings,
            setting_id: subject_in.setting_id,
            timetables: [%{begin: timetable.begin, 
              end: timetable.end,
              weekday: timetable.weekday}]
          },
          type: "subjects"
        }
      }

      conn =
        conn
        |> json_api_headers()
        |> post(Routes.subject_path(conn, :create), struct)
        |> plug_doc(module: TupiWeb.SubjectController, action: :create)
        |> doc()

      assert Bodyguard.permit(Accounts, :create_subject, user) == {:error, :unauthorized}
      assert json_response(conn, 404)["errors"] != []
    end
  end

  describe "Show Subject" do
    test "GET /subjects/:id with valid manager", %{conn: conn, user: user} do
      Accounts.promote_user(user, :manager)
      contest_update(user)
      subject = create_subject_strategy(:subject)

      conn =
        conn
        |> put_req_header("accept", "application/vnd.api+json")
        |> get(Routes.subject_path(conn, :show, subject.id))
        |> doc()

      assert json_response(conn, 200)["data"] != []
      assert Bodyguard.permit(Accounts, :get_subject_preload!, user)
    end

    test "GET /subjects/:id with invalid manager", %{conn: conn, user: user} do
      subject = create_subject_strategy(:subject)

      conn =
        conn
        |> put_req_header("accept", "application/vnd.api+json")
        |> get(Routes.subject_path(conn, :show, subject.id))
        |> plug_doc(module: TupiWeb.SubjectController, action: :show)
        |> doc()

      assert json_response(conn, 404)["errors"] != []
      assert Bodyguard.permit(Accounts, :get_subject_preload!, user) == {:error, :unauthorized}
    end
  end

  describe "Update Subject" do
    test "PUT /subjects/:id with valid manager", %{conn: conn, user: user} do
      Accounts.promote_user(user, :manager)
      contest_update(user)
      subject = create_subject_strategy(:subject)
      timetable = subject.timetables |> List.first
      conflict = subject.conflicts |> List.first

      struct = %{
        data: %{
          attributes: %{
            name: subject.name,
            openings: subject.openings,
            timetables: [%{begin: timetable.begin, 
              end: timetable.end,
              weekday: timetable.weekday}],
            conflicts: [%{subject_code: conflict.subject_code}]
          },
          type: "subjects",
          id: subject.id |> Integer.to_string
        }
      }

      conn =
        conn
        |> json_api_headers()
        |> patch(Routes.subject_path(conn, :update, subject.id), struct)
        |> doc()

      assert Bodyguard.permit(Accounts, :update_subject, user)
      assert json_response(conn, 200)["data"]["attributes"] != %{}
    end

    test "PUT /subjects/:id with invalid manager", %{conn: conn, user: user} do
      subject = create_subject_strategy(:subject)
      timetable = subject.timetables |> List.first

      struct = %{
        data: %{
          attributes: %{
            name: subject.name,
            openings: subject.openings,
            timetables: [%{begin: timetable.begin, 
              end: timetable.end,
              weekday: timetable.weekday}]
          },
          type: "subjects",
          id: subject.id |> Integer.to_string
        }
      }

      conn =
        conn
        |> json_api_headers()
        |> patch(Routes.subject_path(conn, :update, subject.id), struct)
        |> plug_doc(module: TupiWeb.SubjectController, action: :update)
        |> doc()

      assert Bodyguard.permit(Accounts, :update_subject, user) == {:error, :unauthorized}
      assert json_response(conn, 404)["errors"] != []
    end
  end
end
