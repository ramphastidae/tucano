import React from 'react';
import {Button, Container, Form, Message, Segment} from 'semantic-ui-react';
import {handleChange, handleError, tupi} from '../Helpers';

class ForgotPassword extends React.Component {

	constructor(props) {
		super(props);

		this.state = {
			email: '',
			success: false,
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
		document.title = 'Tucano - Recover Password';
	}

	handleChangePassword() {
		tupi(
			'post',
			'/auth/passwords',
			this.handleSuccess,
			this.handleError,
			{
				user: {
					email: this.state.email
				}
			},
		);
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
						<h3>Insert recovery email</h3>
						<Form>
							<Form.Input
								required={true}
								label='Email'
								name='email'
								value={this.state.email}
								onChange={this.handleChange}
							/>
							<Message
								hidden={!this.state.success}
								negative
								size='mini'
								content='A recovery email was successfully sent'
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
								size='large'
								onClick={this.handleChangePassword}
								content='Recover'
							/>
						</Form>
					</Segment>
				</Container>
			</React.Fragment>
		);
	}
}

export default ForgotPassword;
