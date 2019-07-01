import React from 'react';
import {Container, Grid, Icon, Label, Message, Segment} from 'semantic-ui-react';
import {handleChange, handleError, tupi} from "../Shared/Helpers";
import ListItems from "../Shared/ListItems";

class Dashboard extends React.Component {

	constructor(props) {
		super(props);

		this.state = {
			contest: {
				name: '',
				slug: '',
				begin: '',
				end: '',
				id: ''
			},
			user: {
				name: '',
				score: '',
				group: '',
				uniNumber: '',
				id: ''
			},
			error: {
				visible: false,
				message: ''
			},
			loading: true,
		};

		this.handleChange = handleChange.bind(this);
		this.handleError = handleError.bind(this);
		this.handleUser = this.handleUser.bind(this);
		this.handleContest = this.handleContest.bind(this);
	}

	async componentWillMount() {
		document.title = 'Tucano - Contest Dashboard';

		//Show User info
		await tupi(
			'get',
			'/v1/contests/' + this.props.match.params.id + '/applicant',
			this.handleUser,
			this.handleError,
			null,
			{'tenant': this.props.match.params.id}
		);

		//Show Contest info
		await tupi(
			'get',
			'/v1/contests/' + this.props.match.params.id,
			this.handleContest,
			this.handleError
		);
	}

	handleUser(res) {
		if (res && res.hasOwnProperty('data') && res.data.hasOwnProperty('data')) {

			let user = {
				name: res.data.data.attributes.name,
				score: res.data.data.attributes.score.toFixed(3),
				group: res.data.data.attributes.group,
				uniNumber: res.data.data.attributes.uniNumber,
				id: res.data.data.id
			};

			this.setState({
				user: user
			});
		}
	}

	handleContest(res) {
		if (res && res.hasOwnProperty('data') && res.data.hasOwnProperty('data')) {

			let contest = {
				name: res.data.data.attributes.name,
				slug: res.data.data.attributes.slug,
				begin: res.data.data.attributes.begin,
				end: res.data.data.attributes.end,
				id: res.data.data.id
			};

			this.setState({
				contest: contest,
				loading: false
			});
		}
	}

	render() {
		return (
			<React.Fragment>
				<Container className='tableContainer'>
					<Segment color='orange' loading={this.state.loading}>
						<Message
							negative
							hidden={!this.state.error.visible}
							header='Error'
							content={this.state.error.message}
						/>
						<Grid stackable>
							<Grid.Row columns='equal'>
								<Grid.Column>
									<h3>{this.state.contest.name}</h3>
								</Grid.Column>
								<Grid.Column textAlign='right'>
									<Label color='orange' tag={true} size='large'>
										STATUS: {
										new Date(this.state.contest.end.split('T')[0]).setHours(0,0,0,0)
											>= new Date().setHours(0,0,0,0)
										&& new Date(this.state.contest.begin.split('T')[0]).setHours(0,0,0,0)
												<= new Date().setHours(0,0,0,0)
											? 'ACTIVE' : 'INACTIVE'}
									</Label>
								</Grid.Column>
							</Grid.Row>
							<Grid.Row columns='equal'>
								<Grid.Column stretched>
									<Segment color='black'>
										<h5>My Info</h5>
										<Grid>
											<Grid.Row columns='equal'>
												<Grid.Column>
													<Grid.Row>
														<Icon name='id card'/> {this.state.user.uniNumber}
													</Grid.Row>
													<Grid.Row>
														<Icon name='user'/> {this.state.user.name}
													</Grid.Row>
												</Grid.Column>
												<Grid.Column>
													<Grid.Row>
														<Icon name='star'/> {this.state.user.score}
													</Grid.Row>
													<Grid.Row>
														<Icon name='folder'/> {this.state.user.group}
													</Grid.Row>
												</Grid.Column>
											</Grid.Row>
										</Grid>
									</Segment>
								</Grid.Column>
								<Grid.Column stretched>
									<Segment color='black'>
										<h5>CONTEST PERIOD</h5>
										<p>
											<b>Start Date:</b> {this.state.contest.begin.split('T')[0]} <br/>
											<b>End Date:</b> {this.state.contest.end.split('T')[0]}
										</p>
									</Segment>
								</Grid.Column>
							</Grid.Row>
						</Grid>
					</Segment>
					{this.state.user.id !== '' ?
						<ListItems
							kind='Problem'
							api={'/v1/applicants/' + this.state.user.id + '/incoherences'}
							extraRoute='/problems'
							add
							headers={{tenant: this.props.match.params.id}}
							fields={{
								description: 'Description',
								status: 'Status'
							}}
							{...this.props}
						/>
						: ""
					}
				</Container>
			</React.Fragment>
		);
	}
}

export default Dashboard;
