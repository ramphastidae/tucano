import React from 'react';
import {Button, Container, Form, Message, Segment} from 'semantic-ui-react';
import {handleChange, handleError, tupi} from '../Helpers';

class ChangePassword extends React.Component {

	constructor(props) {
		super(props);

		this.state = {
			password: '',
			confirmPassword: '',
			token: '',
			errorDiff: false,
			errorInvalid: false,
			error:{
				visible: false,
				message: '',
			}
		};

		this.handleError = handleError.bind(this);
		this.handleChange = handleChange.bind(this);
		this.handleSuccess = this.handleSuccess.bind(this);
		this.handleChangePassword = this.handleChangePassword.bind(this);
	}

	componentDidMount() {
		document.title = 'Tucano - Change Password';

		const url_string = window.location.href;
		const url = new URL(url_string);
		this.setState({token: url.searchParams.get('token')});
	}

	handleChangePassword() {
		if ((/^.{8,}$/g.exec(this.state.password)) == null) {
			this.setState({errorInvalid: true});
		} else if (this.state.password !== this.state.confirmPassword) {
			this.setState({errorDiff: true});
		} else {
			tupi(
				'put',
				'/auth/passwords/' + this.state.token,
				this.handleSuccess,
				this.handleError,
				{
					user: {
						password: this.state.password
					}
				},
			);
		}
	}

	handleSuccess() {
		this.props.history.push('/');
		this.props.history.push('/login');
	}

	render() {
		return (
			<React.Fragment>
				<Container className='tableContainer'>
					<Segment color='orange'>
						<h3>Insert New Password</h3>
						<Form>
							<Form.Input
								required={true}
								label='New Password'
								name='password'
								type='password'
								value={this.state.password}
								onChange={this.handleChange}
							/>
							<Form.Input
								required={true}
								label='Confirm Password'
								name='confirmPassword'
								type='password'
								value={this.state.confirmPassword}
								onChange={this.handleChange}
							/>
							<Message
								hidden={!this.state.errorInvalid}
								negative
								size='mini'
								content='Must have more than 8 characters'
							/>
							<Message
								hidden={!this.state.errorDiff}
								negative
								size='mini'
								content='Passwords do not match'
							/>
							<Message
								hidden={!this.state.error.visible}
								negative
								size='mini'
								content={this.state.error.message}
							/>
							<Button
								icon='key'
								labelPosition='left'
								color='orange'
								onClick={this.handleChangePassword}
								content='Change'
							/>
						</Form>
					</Segment>
				</Container>
			</React.Fragment>
		);
	}
}

export default ChangePassword;
