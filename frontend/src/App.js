import React, {Component} from 'react';
import {Redirect, Route, Switch} from "react-router-dom";
import Login from "./Shared/Authentication/Login";
import ManagersAdmin from "./Admin/Managers";
import NewManager from "./Admin/Managers/New";
import EditManager from "./Admin/Managers/Edit";
import ContestSelection from "./Shared/ContestSelection";
import NewContest from "./Manager/Contest/New";
import ManagerDashboard from "./Manager/Dashboard";
import UserDashboard from "./User/Dashboard";
import ChangePassword from "./Shared/Authentication/ChangePassword";
import MyFooter from "./Footer/MyFooter";
import Header from './Header/Header';
import Error404 from "./Shared/Errors/Error404";
import EditDates from "./Manager/Contest/EditDates";
import EditSubjects from "./Manager/Subjects/Edit";
import NewSubjects from "./Manager/Subjects/New";
import NewUsers from "./Manager/Users/New";
import EditUsers from "./Manager/Users/Edit";
import Subjects from "./Manager/Subjects";
import Users from "./Manager/Users";
import Application from "./User/Application";
import Results from "./User/Results";
import About from "./Shared/About";
import NewProblem from "./User/Problems/New";
import ConfirmUserDelete from "./Manager/Users/ConfirmUserDelete";
import DeleteProblem from "./User/Problems/Delete";
import './App.css';
import ForgotPassword from "./Shared/Authentication/ForgotPassword";
import ErrorBoundary from "./Shared/Errors/ErrorBoundary";
import ConfirmPublish from "./Manager/ConfirmPublish";
import ConfirmContestDelete from "./Manager/Contest/ConfirmContestDelete";


function PrivateRoute({component: Component, render, ...rest}) {
    if (!!localStorage.getItem('token')) {
        return (
            <Route {...rest} render={render
                ? render
                : (props => <Component {...props}/>)
            }/>
        )
    } else {
        return (
            <Route {...rest} render={props => {
                props.history.push(props.location.pathname);
                return <Redirect to='/login'/>
            }}/>
        )
    }
}

class App extends Component {

    render() {
        const base_switch = {
            admin:
                (<React.Fragment>
                    <Switch>
                        <PrivateRoute path='/' render={props => <Header {...props} value='admin'/>}/>
                    </Switch>
                    <Switch>
                        <PrivateRoute exact path='/admin/managers' component={ManagersAdmin}/>
                        <PrivateRoute exact path='/admin/managers/new' component={NewManager}/>
						<PrivateRoute exact path='/admin/managers/:id/edit' component={EditManager}/>
                        <PrivateRoute exact path='/' render={() => <Redirect to='/admin/managers'/>}/>
						<PrivateRoute exact path='/about' component={About}/>
                        <Route exact path='/password/edit/:token?' component={ChangePassword}/>
                        <Redirect exact from='/login' to='/'/>
						<Redirect from='/resources' to='/'/>
                        <Route path='/' component={Error404}/>
                    </Switch>
                </React.Fragment>),
            manager:
                (<React.Fragment>
                    <Switch>
                        <PrivateRoute path='/manager/contests/new'
                                      render={props => <Header {...props} value='manager'/>}/>
                        <PrivateRoute path='/manager/contests/:contest'
                                      render={props => <Header {...props} value='managerContest'/>}/>
                        <PrivateRoute path='/' render={props => <Header {...props} value='manager'/>}/>
                    </Switch>
                    <Switch>
                        <PrivateRoute exact path='/manager/contests' component={ContestSelection}/>
                        <PrivateRoute exact path='/manager/contests/new' component={NewContest}/>
                        <Redirect exact from='/manager/contests/:id' to='/manager/contests/:id/dashboard'/>
                        <PrivateRoute exact path='/manager/contests/:id/dashboard' component={ManagerDashboard}/>
                        <PrivateRoute exact path='/manager/contests/:id' component={ManagerDashboard}/>
                        <PrivateRoute exact path='/manager/contests/:id/dates/edit' component={EditDates}/>
                        <PrivateRoute exact path='/manager/contests/:id/subjects/:subject/edit' component={EditSubjects}/>
                        <PrivateRoute exact path='/manager/contests/:id/subjects/new' component={NewSubjects}/>
                        <PrivateRoute exact path='/manager/contests/:id/subjects' component={Subjects}/>
                        <PrivateRoute exact path='/manager/contests/:id/users/:user/edit' component={EditUsers}/>
                        <PrivateRoute exact path='/manager/contests/:id/users/new' component={NewUsers}/>
                        <PrivateRoute exact path='/manager/contests/:id/users' component={Users}/>
                        <PrivateRoute exact path='/manager/contests/:id/users/delete/all' component={ConfirmUserDelete}/>
                        <PrivateRoute exact path='/manager/contests/:id/publish-results' component={ConfirmPublish}/>
                        <PrivateRoute exact path='/manager/contests/:id/confirm-delete' component={ConfirmContestDelete}/>
                        <PrivateRoute exact path='/' render={() => <Redirect to='/manager/contests'/>}/>
						<PrivateRoute exact path='/about' component={About}/>
                        <Route exact path='/password/edit/:token?' component={ChangePassword}/>
                        <Redirect exact from='/login' to='/'/>
						<Redirect from='/resources' to='/'/>
                        <Route path='/' component={Error404}/>
                    </Switch>
                </React.Fragment>),
            normal:
                (<React.Fragment>
                    <Switch>
                        <PrivateRoute path='/user/contests/:contest'
                                      render={props => <Header {...props} value='userContest'/>}/>
                        <PrivateRoute path='/' render={props => <Header {...props} value='user'/>}/>
                    </Switch>
                    <Switch>
                        <PrivateRoute exact path='/user/contests' component={ContestSelection}/>
                        <PrivateRoute exact path='/' render={() => <Redirect to='/user/contests'/>}/>
                        <Redirect exact from='/user/contests/:id' to='/user/contests/:id/dashboard'/>
                        <PrivateRoute exact path='/user/contests/:id/dashboard' component={UserDashboard}/>
                        <PrivateRoute exact path='/user/contests/:id/dashboard/problems/new' component={NewProblem}/>
                        <PrivateRoute exact path='/user/contests/:id' component={UserDashboard}/>
                        <PrivateRoute exact path='/user/contests/:id/application' component={Application}/>
                        <PrivateRoute exact path='/user/contests/:id/results' component={Results}/>
                        <PrivateRoute exact path='/user/contests/:id/dashboard/problems/:problem/edit' component={DeleteProblem}/>
						<PrivateRoute exact path='/about' component={About}/>
                        <Route exact path='/password/edit/:token?' component={ChangePassword}/>
                        <Redirect exact from='/login' to='/'/>
						<Redirect from='/resources' to='/'/>
                        <Route path='/' component={Error404}/>
                    </Switch>
                </React.Fragment>),
            other:
                (<React.Fragment>
                    <Switch>
                        <Route path='/' render={props => <Header {...props} value='simple'/>}/>
                    </Switch>
                    <Switch>
                        <Route exact path='/login' component={Login}/>
                        <Route exact path='/about' component={About}/>
                        <Route exact path='/forgot-password' component={ForgotPassword}/>
                        <Route exact path='/password/edit/:token?' component={ChangePassword}/>
                        <Route path='/' render={props => {
                            props.history.push(props.location.pathname);
                            return <Redirect to='/login'/>
                        }}/>
                    </Switch>
                </React.Fragment>)
        }[localStorage.getItem('usertype') || 'other'];

        return (
            <ErrorBoundary>
                <React.Fragment>
                    <div id="page-container">
                        <div id="content-wrap">
                            {base_switch}
                        </div>
                        <footer id="footer"><MyFooter/></footer>
                    </div>
                </React.Fragment>
            </ErrorBoundary>
        );
    }
}

export default App;
