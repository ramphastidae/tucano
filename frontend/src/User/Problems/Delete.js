import React from 'react';
import {Button, Container, Form, Grid, Message, Segment} from 'semantic-ui-react';
import {handleError, tupi} from '../../Shared/Helpers';

class DeleteProblem extends React.Component {
	constructor(props) {
		super(props);

		this.state = {
			description: '',
			id: '',
			status: '',
			loading: false,
			error: {
				visible: false,
				message: ''
			}
		};

		this.handleError = handleError.bind(this);
		this.handleClick = this.handleClick.bind(this);
		this.handleSuccess = this.handleSuccess.bind(this);
		this.handleUser = this.handleUser.bind(this);
		this.handleProblem = this.handleProblem.bind(this);
	}

	async componentWillMount() {
		document.title = 'Tucano - Delete Problem';

		this.setState({loading: true});
		await tupi(
			'get',
			'/v1/contests/' + this.props.match.params.id + '/applicant',
			this.handleUser,
			this.handleError,
			null,
			{'tenant': this.props.match.params.id}
		);
		await tupi(
			'get',
			'/v1/applicants/' + this.state.id + '/incoherences/' + this.props.match.params.problem,
			this.handleProblem,
			this.handleError,
			null,
			{'tenant': this.props.match.params.id}
		);
	}

	handleUser(res) {
		if (res && res.hasOwnProperty('data') && res.data.hasOwnProperty('data')) {
			this.setState({
				id: res.data.data.id,
			});
		}
	}

	handleProblem(res) {
		if (res && res.hasOwnProperty('data') && res.data.hasOwnProperty('data')) {
			this.setState({
				description: res.data.data[0].attributes.description,
				status: res.data.data[0].attributes.status,
				loading: false
			});
		}
	}

	handleClick() {
		if(this.state.description !== '') {
			tupi(
				'delete',
				'/v1/applicants/' + this.state.id + '/incoherences/' + this.props.match.params.problem,
				this.handleSuccess,
				this.handleError,
				null,
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
						<Grid columns='equal'>
							<Grid.Column>
								<h3>Edit Problem</h3>
							</Grid.Column>
							<Grid.Column textAlign='right'>
								<Button
									basic
									icon='times'
									labelPosition='left'
									color='orange'
									size='small'
									onClick={this.handleClick}
									content='Delete Problem'
								/>
							</Grid.Column>
						</Grid>
						<Form>
							<Form.TextArea
								disabled={true}
								label='Description'
								name='description'
								value={this.state.description}
							/>
							<Form.Input
								disabled={true}
								label='Status'
								name='status'
								value={this.state.status}
							/>
							<Message
								hidden={!this.state.error.visible}
								negative
								header='Error'
								content={this.state.error.message}
							/>
						</Form>
					</Segment>
				</Container>
			</React.Fragment>
		);
	}
}

export default DeleteProblem;
