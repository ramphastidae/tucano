import React from 'react';
import {Button, Container, Form, Message, Segment} from 'semantic-ui-react';
import {handleError, handleChange, tupi} from '../../Shared/Helpers';

class AddManagers extends React.Component {
	constructor(props) {
		super(props);

		this.state = {
			name: '',
			email: '',
			error: {
				visible: false,
				message: ''
			}
		};

		this.handleChange = handleChange.bind(this);
		this.handleError = handleError.bind(this);
		this.handleAddManagerClick = this.handleAddManagerClick.bind(this);
		this.handleSuccess = this.handleSuccess.bind(this);
	}

	componentDidMount() {
		document.title = 'Tucano - Add New Manager';
	}

	handleAddManagerClick() {
		if(this.state.name !== '' && this.state.email !== '') {
			tupi(
				'post',
				'/v1/managers',
				this.handleSuccess,
				this.handleError,
				{
					'data': {
						attributes: {
							email: this.state.email,
							name: this.state.name
						},
						type: 'manager'
					}
				}
			);
		}
		else {
			let error = {visible: true, message: 'Please fill all required fields'};
			this.setState({error: error});
		}
	}

	handleSuccess() {
		this.props.history.push('/');
	}

	render() {
		return (
			<React.Fragment>
				<Container className='tableContainer'>
					<Segment color='orange'>
						<h3>Add New Manager</h3>
						<Form>
							<Form.Input
								required={true}
								label='Email'
								name='email'
								value={this.state.email}
								onChange={this.handleChange}
							/>
							<Form.Input
								required={true}
								label='Name'
								name='name'
								value={this.state.name}
								onChange={this.handleChange}
							/>
							<Message
								hidden={!this.state.error.visible}
								negative
								header='Error'
								content={this.state.error.message}
							/>
							<Button
								icon='add user'
								labelPosition='left'
								color='orange'
								size='small'
								onClick={this.handleAddManagerClick}
								content='Add Manager'
							/>
						</Form>
					</Segment>
				</Container>
			</React.Fragment>
		);
	}
}

export default AddManagers;
