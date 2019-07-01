import React from 'react';
import {Button, Form, Grid, Image, Message, Modal, Segment} from 'semantic-ui-react';
import Pdf from '../../resources/Cookies-Policy-Tucano.pdf';
import {handleError, handleChange, tupi} from '../Helpers';
import cookie from '../../resources/cookie.BMP';
import './Login.css';
import {Link} from "react-router-dom";

class Login extends React.Component {
    constructor(props) {
        super(props);

        this.state = {
            email: '',
            password: '',
            acceptCookie: true,
            error: {
                visible: false,
                message: ''
            }
        };

        this.handleChange = handleChange.bind(this);
        this.handleError = handleError.bind(this);
        this.handleSuccessfulLogin = this.handleSuccessfulLogin.bind(this);
        this.handleUserType = this.handleUserType.bind(this);
        this.handleLogin = this.handleLogin.bind(this);
        this.acceptCookies = this.acceptCookies.bind(this);
    }

    shouldComponentUpdate() {
        if ((localStorage.getItem('token') || '').length) {
            this.handleSuccessfulLogin();
            return false;
        } else {
            return true;
        }
    }

    componentWillMount() {
        document.title = 'Tucano - Login';

        if (!!localStorage.getItem('acceptCookies')) {
             this.setState({acceptCookie: false});
        }
    }

    handleLogin() {
        tupi(
            'post',
            '/auth/sign_in',
            this.handleSuccessfulLogin,
            this.handleError,
            {
                email: this.state.email,
                password: this.state.password
            }
        );
    }

    handleSuccessfulLogin(res) {
        if (res && res.hasOwnProperty('data')) {
            localStorage.setItem('token', res.data.jwt);

            tupi(
                'get',
                '/v1/users',
                this.handleUserType,
                this.handleError
            );
        }
    }

    handleUserType(res) {
        if (res && res.data && res.data.hasOwnProperty('data')) {
            localStorage.setItem('usertype', res.data.data[0].attributes.level);
            localStorage.setItem('userid', res.data.data[0].id);
            this.props.history.goBack();
        }
    }

    acceptCookies(){
        localStorage.setItem('acceptCookies', 'true');
        this.setState({acceptCookie: false})
    }

    render() {
        const CookieBanner = () => (
            <Modal
                open={this.state.acceptCookie}
                closeOnEscape={false}
                closeOnDimmerClick={false}
            >
                <Modal.Header>We Use Cookies</Modal.Header>
                <Grid>
                    <Grid.Column width={4}>
                        <p/>
                        <Image size='small' src={cookie}/>
                        <p/>
                    </Grid.Column>
                    <Grid.Column width={12} verticalAlign='middle' textAlign='left'>
                        <p>
                            We use cookies and other tracking technologies to improve
                            your browsing experience on our website, to show you
                            personalized content and to analyze our website traffic.
                            By browsing our website, you consent to our use of
                            cookies and other tracking technologies.&nbsp;
                            <a href={Pdf} target='_blank' rel='noopener noreferrer'>Cookie Policy</a>
                        </p>
                    </Grid.Column>
                </Grid>
                <Modal.Actions>
                    <Button
                        onClick={this.acceptCookies}
                        positive
                        labelPosition='right'
                        icon='checkmark'
                        content='I agree'
                    />
                </Modal.Actions>
            </Modal>
        );

        return (
            <React.Fragment>
                <CookieBanner/>
                <Grid equal='true' stackable centered className='login-form'>
                    <Grid.Row verticalAlign='bottom'>
                        <Grid.Column className='grid-col'>
                            <h3 className='grid-col'>
                                Welcome, log-in to your account
                            </h3>
                            <Form size='large'>
                                <Segment raised>
                                    <Form.Input
                                        fluid
                                        type='email'
                                        icon='user'
                                        iconPosition='left'
                                        placeholder='E-mail'
                                        name='email'
                                        value={this.state.email}
                                        onChange={this.handleChange}
                                    />
                                    <Form.Input
                                        fluid
                                        icon='lock'
                                        iconPosition='left'
                                        placeholder='Password'
                                        type='password'
                                        name='password'
                                        value={this.state.password}
                                        onChange={this.handleChange}
                                    />
                                    <Message
                                        hidden={!this.state.error.visible}
                                        negative
                                        header='Error'
                                        content='Invalid email or password.'
                                    />
                                    <Button color='orange' fluid size='large' onClick={this.handleLogin}>
                                        Login
                                    </Button>
                                </Segment>
                            </Form>
                        </Grid.Column>
                    </Grid.Row>
                    <Grid.Row verticalAlign='top'>
                        <Grid.Column className='grid-col' textAlign='center'>
                            <Message>
                                <Link to='/forgot-password'>Forgot your password?</Link>
                            </Message>
                        </Grid.Column>
                    </Grid.Row>
                </Grid>
            </React.Fragment>
        );
    }
}

export default Login;
