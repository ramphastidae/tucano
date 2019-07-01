import React from 'react';
import {Container, Divider, Grid, List, Message, Segment} from 'semantic-ui-react';
import {handleError, tupi} from "../Shared/Helpers";

class Results extends React.Component {
	constructor(props) {
		super(props);
		this.state = {
			id: '',
			initialData: {},
			contest: '',
			subjects: [],
			loading: false,
			error: {
				visible: false,
				message: ''
			}
		};

		this.handleError = handleError.bind(this);
		this.handleUser = this.handleUser.bind(this);
		this.handleResults = this.handleResults.bind(this);
	}

	componentWillMount() {
		document.title = 'Tucano - User Results';

		this.setState({contest: this.props.match.params.id});

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
			this.setState({id: res.data.data.id});

			tupi(
				'get',
				'/v1/applicants/' + res.data.data.id + '/results',
				this.handleResults,
				this.handleError,
				null,
				{'tenant': this.props.match.params.id}
			);
		}
	}

	handleResults(res) {
		if (res && res.hasOwnProperty('data') && res.data.hasOwnProperty('data')) {
			this.treatIncludedData(res.data.included, res.data.data);
		}

		this.handleOrderSubjects();
	}

	handleOrderSubjects() {
		let res = this.state.subjects;
		let t = {};

		// eslint-disable-next-line array-callback-return
		res.map(sub => {
			let s = sub.attributes;
			if(!t.hasOwnProperty(s.setting))
				t[sub.attributes.setting] = [];
			t[s.setting].push({code: s.code, name: s.name})
		});

		this.setState({initialData: t});
	}

	treatIncludedData(included, data) {

		for(let i=0; i<data.length; i++) {
			data[i].attributes['conflicts'] = "";

			for(let j=0; j<included.length; j++) {

				// settings
				if(included[j].type === "settings") {
					if(data[i].relationships.setting.data.id === included[j].id) {
						data[i].attributes['setting'] = included[j].attributes.typeKey;
						data[i].attributes['settingId'] = data[i].relationships.setting.data.id;
					}
				}
				// conflicts
				if(included[j].type === "conflicts") {
					// eslint-disable-next-line array-callback-return
					data[i].relationships.conflicts.data.map(e => {
						if(e.id === included[j].id){
							let conflict;

							if(data[i].attributes.conflicts === "")
								conflict = included[j].attributes.subjectCode;
							else
								conflict = ', ' + included[j].attributes.subjectCode;

							data[i].attributes.conflicts = data[i].attributes.conflicts + conflict;
						}
					});
				}
			}
		}
		this.setState({subjects: data, loading: false});
	}

	render() {
		return (
			<React.Fragment>
				<Container className='tableContainer'>
					<Segment color='orange' loading={this.state.loading}>
						<Grid columns='equal' stackable>
							<Grid.Column>
								<h3>My Results</h3>
							</Grid.Column>
						</Grid>

						<Message
							negative
							hidden={!this.state.error.visible}
							header='Error'
							content='There are no available results'
						/>

						{Object.keys(this.state.initialData).map(subgroup => (
							<Container>
								<Divider horizontal>
									<h3>{subgroup}</h3>
								</Divider>
								<Segment>
									<List divided relaxed='very' size='large'>
										{this.state.initialData[subgroup].map(item => (
											<List.Item>
												<List.Content>
													{item.code}: {item.name}
												</List.Content>
											</List.Item>)
										)}
									</List>
								</Segment>
							</Container>
						))}
					</Segment>
				</Container>
			</React.Fragment>
		);
	}
}

export default Results;
