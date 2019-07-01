import React from 'react';
import {Button, Container, Form, Grid, List, Message, Segment} from 'semantic-ui-react';
import {handleError, handleChange, tupi} from '../../Shared/Helpers.js';

class EditUsers extends React.Component {
	constructor(props) {
		super(props);

		this.state = {
			idCode: '',
			name: '',
			email: '',
			group: '',
			score: '',
			contest: '',
			id: '',
			problems: [],
			loading: 2,
			error: {
				visible: false,
				message: ''
			},
			success: false,
		};

		this.handleChange = handleChange.bind(this);
		this.handleError = handleError.bind(this);
		this.handleEdit = this.handleEdit.bind(this);
		this.handleApplicant = this.handleApplicant.bind(this);
		this.handleDelete = this.handleDelete.bind(this);
		this.handleSuccess = this.handleSuccess.bind(this);
		this.handleProblems = this.handleProblems.bind(this);
		this.handleUpdateProblem = this.handleUpdateProblem.bind(this);
		this.handleSuccessUpdate = this.handleSuccessUpdate.bind(this);
	}

	componentWillMount() {
		document.title = 'Tucano - Edit User';
		this.setState({
				id: this.props.match.params.user,
				contest: this.props.match.params.id,
				loading: true,
			}
		);

		tupi(
			'get',
			'/v1/applicants/' + this.props.match.params.user,
			this.handleApplicant,
			this.handleError,
			null,
			{'tenant': this.props.match.params.id}
		);
		tupi(
			'get',
			'/v1/applicants/' + this.props.match.params.user + '/incoherences',
			this.handleProblems,
			this.handleError,
			null,
			{'tenant': this.props.match.params.id}
		);

	}

	handleApplicant(res) {
		if (res && res.hasOwnProperty('data') && res.data.hasOwnProperty('data')) {
			const attributes = res.data.data.attributes;

			this.setState({
				name: attributes.name || 'No name specified',
				email: attributes.email || 'No email specified',
				group: attributes.group || 'No group specified',
				score: attributes.score.toFixed(3) || 'No score specified',
				idCode: attributes.uniNumber || 'No unique number specified',
				loading: false
			});
		}
	}

	handleProblems(res) {
		if (res && res.hasOwnProperty('data') && res.data.hasOwnProperty('data')) {
			this.setState({problems: res.data.data, loading: false});
		}
	}

	handleEdit(event) {
		let score = parseFloat(this.state.score);

		if (!isNaN(score)) {
			tupi(
				'patch',
				'/v1/applicants/' + this.props.match.params.user,
				this.handleSuccess,
				this.handleError,
				{
					'data': {
						attributes: {
							group: this.state.group,
							score: score + 0.00001,
						},
						id: this.props.match.params.user,
						type: 'applicants'
					}
				},
				{'tenant': this.state.contest}
			);
		} else {
			this.setState({error: {visible: true, message: 'Invalid score value.'}});
		}
	}

	handleDelete(event) {
		tupi(
			'delete',
			'/v1/applicants/' + this.props.match.params.user,
			this.handleSuccess,
			this.handleError,
			null,
			{'tenant': this.props.match.params.id}
		);
	}

	handleSuccess(res) {
		this.props.history.push('/manager/contests/' + this.props.match.params.id + '/users');
	}

	handleUpdateProblem(event, el) {
		tupi(
			'patch',
			'/v1/incoherences/' + el.problem,
			this.handleSuccessUpdate,
			this.handleError,
			{
				data: {
					attributes:{
						status: el.action
					},
					id: el.problem,
					type: 'incoherences'
				}
			},
			{'tenant': this.props.match.params.id}
		);
	}

	handleSuccessUpdate(res) {
		let probs = this.state.problems;
		for(let i=0; i<probs.length; i++) {
			if(probs[i].id === res.data.data.id){
				probs[i].attributes.status = res.data.data.attributes.status;
			}
		}
		this.setState({problems: probs});
	}

	render() {
		return (
			<div>
				<Container className='tableContainer'>
					<Segment color='orange' loading={this.state.loading}>
						<Grid columns='equal'>
							<Grid.Column>
								<h3>Edit User</h3>
							</Grid.Column>
							<Grid.Column textAlign='right'>
								<Button
									basic
									icon='remove user'
									labelPosition='left'
									color='orange'
									onClick={this.handleDelete}
									content='Delete User'
								/>
							</Grid.Column>
						</Grid>
						<Form>
							<Form.Input
								disabled
								label='Id Code'
								name='IdCode'
								value={this.state.idCode}
							/>
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
							<Form.Input
								label='Group'
								name='group'
								value={this.state.group}
								onChange={this.handleChange}
							/>
							<Form.Input
								required={true}
								label='Score'
								name='score'
								type='number'
								value={this.state.score}
								onChange={this.handleChange}
							/>
							<Message
								hidden={!this.state.success}
								success
								header='User edited'
								content="The new user was edited with success"
							/>
							<Message
								hidden={!this.state.error.visible}
								negative
								header='Update of User failed'
								content={this.state.error.message}
							/>
							<Button
								icon='edit'
								labelPosition='left'
								color='orange'
								size='large'
								onClick={this.handleEdit}
								content='Confirm Changes'
							/>
						</Form>
					</Segment>
						{this.state.problems.length !== 0 ?
							<Segment color='orange'>
								<h3>User Problems</h3>
								<List divided verticalAlign='middle'>
									{this.state.problems.map((problem) => (
										<List.Item key={problem.id}>
											<List.Content floated='right'>
												<Button.Group>
													<Button
														problem={problem.id}
														action='unviewed'
														icon='eye slash'
														active={problem.attributes.status === 'unviewed'}
														onClick={this.handleUpdateProblem}
													/>
													<Button
														problem={problem.id}
														action='viewed'
														icon='eye'
														active={problem.attributes.status === 'viewed'}
														onClick={this.handleUpdateProblem}
													/>
													<Button
														problem={problem.id}
														action='solved'
														icon='check'
														active={problem.attributes.status === 'solved'}
														onClick={this.handleUpdateProblem}
													/>
												</Button.Group>
											</List.Content>
											<List.Content>
												{problem.attributes.description}
											</List.Content>
										</List.Item>
										)
									)}
								</List>
							</Segment>
							: ""
						}
				</Container>
			</div>
		);
	}
}

export default EditUsers;
