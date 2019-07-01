import React from 'react';
import {Button, Container, Form, Message, Segment} from 'semantic-ui-react';
import {handleError, handleChange, tupi} from '../../Shared/Helpers';

class EditManager extends React.Component {
	constructor(props) {
		super(props);

		this.state = {
			id: '',
			name: '',
			email: '',
			status: '',
			error: {
				visible: false,
				message: ''
			}
		};

		this.handleChange = handleChange.bind(this);
		this.handleError = handleError.bind(this);
		this.handleConfirmChangesClick = this.handleConfirmChangesClick.bind(this);
		this.handleManager = this.handleManager.bind(this);
		this.handleSuccess = this.handleSuccess.bind(this);
	}

	componentWillMount() {
		document.title = 'Tucano - Edit Manager';
		this.setState({id: this.props.match.params.id});

		tupi(
			'get',
			'/v1/managers/' + this.props.match.params.id,
			this.handleManager,
			this.handleError
		);
	}

	handleManager(res) {
		if (res && res.hasOwnProperty('data') && res.data.hasOwnProperty('data')) {
			this.setState({
				name: res.data.data.attributes.name || 'No name specified',
				email: res.data.data.attributes.email || 'No email specified',
				status: res.data.data.attributes.status || ''
			});
		}
	}

	handleConfirmChangesClick(event) {
		tupi(
			'patch',
			'/v1/managers/' + this.state.id,
			this.handleSuccess,
			this.handleError,
			{
				'data': {
				attributes: {
					email: this.state.email,
					status: this.state.status

				},
				id: this.state.id,
				type: "managers"
				}
			}
		);
	};

	handleSuccess(res) {
		this.props.history.push('/');
	}

	render() {
		const options = [
			{key: 'a', text: 'Active', value: 'active'},
			{key: 'i', text: 'Inactive', value: 'inactive'},
		];

		return (
			<div>
				<Container className='tableContainer'>
					<Segment color='orange'>
						<h3>Edit Manager</h3>
						<Form>
							<Form.Input
								disabled
								label='Email'
								name='email'
								value={this.state.email}
							/>
							<Form.Input
								disabled
								label='Name'
								name='name'
								value={this.state.name}
							/>
							<Form.Dropdown
								label='Status'
								name='status'
								fluid
								selection
								onChange={(e, item) => this.handleChange(item)}
								value={this.state.status}
								options={options}
							/>
							<Message
								hidden={!this.state.error.visible}
								negative
								header='Error'
								content={this.state.error.message}
							/>
							<Button
								icon='edit'
								labelPosition='left'
								color='orange'
								size='large'
								onClick={this.handleConfirmChangesClick}
								content='Confirm Changes'
							/>
						</Form>
					</Segment>
				</Container>
			</div>
		);
	}
}

export default EditManager;
