import React from 'react';
import {Button, Container, Form, Message, Segment} from 'semantic-ui-react';
import {handleError, handleChange, tupi} from '../../Shared/Helpers';

class NewProblem extends React.Component {
	constructor(props) {
		super(props);

		this.state = {
			description: '',
			id: '',
			loading: false,
			error: {
				visible: false,
				message: ''
			}
		};

		this.handleChange = handleChange.bind(this);
		this.handleError = handleError.bind(this);
		this.handleClick = this.handleClick.bind(this);
		this.handleSuccess = this.handleSuccess.bind(this);
		this.handleUser = this.handleUser.bind(this);
	}

	componentWillMount() {
		document.title = 'Tucano - Add New Problem';

		this.setState({loading: true});
		tupi(
			'get',
			'/v1/contests/' + this.props.match.params.id + '/applicant',
			this.handleUser,
			this.handleError,
			null,
			{'tenant': this.props.match.params.id}
		);
	}

	handleUser(res) {
		if (res && res.hasOwnProperty('data') && res.data.hasOwnProperty('data')) {

			this.setState({
				id: res.data.data.id,
				loading: false
			});
		}
	}

	handleClick() {
		if(this.state.description !== '') {
			tupi(
				'post',
				'/v1/applicants/' + this.state.id + '/incoherences',
				this.handleSuccess,
				this.handleError,
				{
					'data': {
						attributes: {
							applicant_id: this.state.id,
							description: this.state.description
						},
						type: 'incoherences'
					}
				},
				{'tenant': this.props.match.params.id}
			);
		}
	}

	handleSuccess() {
		this.props.history.push('/user/contests/' + this.props.match.params.id);
	}

	render() {
		return (
			<React.Fragment>
				<Container className='tableContainer'>
					<Segment color='orange' loading={this.state.loading}>
						<h3>Add New Problem</h3>
						<Form>
							<Form.TextArea
								required={true}
								label='Description'
								name='description'
								value={this.state.description}
								onChange={this.handleChange}
							/>
							<Message
								hidden={!this.state.error.visible}
								negative
								header='Error'
								content={this.state.error.message}
							/>
							<Button
								icon='add'
								labelPosition='left'
								color='orange'
								size='small'
								onClick={this.handleClick}
								content='Add Problem'
							/>
						</Form>
					</Segment>
				</Container>
			</React.Fragment>
		);
	}
}

export default NewProblem;
