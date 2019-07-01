import React from 'react';
import {Button, Container, Grid, Message, Segment} from 'semantic-ui-react';
import {DragDropContext} from 'react-beautiful-dnd';
import Column from './Application/Column';
import {handleChange, handleError, tupi} from "../Shared/Helpers";

class Application extends React.Component {

	constructor(props) {
		super(props);
		this.state = {
			id: '',
			initialData: {
				tasks: {},
				columns: {},
				columnOrder: []
			},
			subjects: [],
			contest: '',
			loading: true,
			success: false,
			warning: false,
			error: {
				visible: false,
				message: ''
			}
		};

		this.handleChange = handleChange.bind(this);
		this.handleError = handleError.bind(this);
		this.onDragEnd = this.onDragEnd.bind(this);
		this.handleSave = this.handleSave.bind(this);
		this.handleUser = this.handleUser.bind(this);
		this.handleApplications = this.handleApplications.bind(this);
		this.handleSubjects = this.handleSubjects.bind(this);
		this.handleSuccess = this.handleSuccess.bind(this);
	}

	componentWillMount() {
		document.title = 'Tucano - User Application';

		this.setState({
			contest: this.props.match.params.id,
			loading: true
		});

		tupi(
			'get',
			'/v1/contests/' + this.props.match.params.id + '/applicant',
			this.handleUser,
			this.handleError,
			null,
			{'tenant': this.props.match.params.id}
		);
	}

	async handleUser(res) {
		if (res && res.hasOwnProperty('data') && res.data.hasOwnProperty('data')) {

			this.setState({
				id: res.data.data.id
			});

			await tupi(
				'get',
				'/v1/subjects',
				this.handleSubjects,
				this.handleError,
				null,
				{'tenant': this.props.match.params.id}
			);

			await tupi(
				'get',
				'/v1/applicants/' + res.data.data.id + '/applications',
				this.handleApplications,
				this.handleError,
				null,
				{'tenant': this.props.match.params.id}
			);
		}
	}

	handleSubjects(res) {
		if (res && res.hasOwnProperty('data') && res.data.hasOwnProperty('data')) {
			this.treatIncludedData(res.data.included, res.data.data);
		}
	}

	handleApplications(res) {
		if (res && res.hasOwnProperty('data') && res.data.hasOwnProperty('data')) {
			if (res.data.data.length !== 0) {
				this.handleOrderSubjects();
				this.orderSubjects(res.data.data);
			}
			else {
				this.setState({warning: true});
				this.handleOrderSubjects();
			}
		}
		this.setState({loading: false});
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

		this.setState({subjects: data});
	}

	buildPreferences() {

		let columns = this.state.initialData.columns;
		let res = [];

		// eslint-disable-next-line array-callback-return
		Object.keys(columns).map(k => {
			// eslint-disable-next-line array-callback-return
			columns[k].tasksIds.map((t, index) => {
				res.push({preference: index + 1, subject_id: t});
			})
		});
		return res;
	}

	handleSave() {
		this.setState({loading: true, success: false});

		tupi(
			'patch',
			'/v1/applicants/' + this.state.id,
			this.handleSuccess,
			this.handleError,
			{
				'data': {
					attributes: {
						applications: this.buildPreferences()
					},
					id: this.state.id,
					type: 'applicants'
				},
			},
			{'tenant': this.props.match.params.id}
		);
	}

	handleSuccess(res) {
		this.setState({loading: false, success: true, warning: false});
		window.setTimeout(() => {
			this.setState({
				success: false
			});
		}, 5000);
	}

	handleOrderSubjects() {

		let res = this.state.subjects;

		let t={};
		let InitialData = {
			tasks: Object.assign({}, ...res.map(e => ({
				[e.id]: {
					'id': e.id,
					'code': e.attributes.code,
					'content': e.attributes.name,
					'conflicts': e.attributes.conflicts || null}
			}))),
			columnOrder: res.map(e => e.attributes.settingId).filter(e=>!(t[e]=e in t)).sort()
		};

		InitialData.columns = Object.assign(
			{},
			...InitialData.columnOrder.map(settingId => ({
				[settingId]: {
					'id': settingId,
					'title': res.filter(e => e.attributes.settingId === settingId)[0].attributes.setting ,
					'tasksIds': res.filter(e => e.attributes.settingId === settingId).map(e => e.id)}})));

		this.setState({initialData: InitialData});
	}

	orderSubjects(res) {
		let order = [];
		let dataClone = JSON.parse(JSON.stringify(this.state.initialData));

		// eslint-disable-next-line array-callback-return
		res.map(e => {
			order.push(e.relationships.subject.data.id);
		});

		// eslint-disable-next-line array-callback-return
		Object.values(dataClone.columns).map(e => {
			e.tasksIds = [];
		});

		// eslint-disable-next-line array-callback-return
		order.map(o => {
			// eslint-disable-next-line array-callback-return
			Object.values(this.state.initialData.columns).map(e => {
				if(e.tasksIds.includes(o)) {
					dataClone.columns[e.id].tasksIds.push(o);
				}
			});
		});
		this.setState({initialData: dataClone});
	}

	onDragEnd(result) {

		const {destination, source, draggableId} = result;

		if (!destination) {
			return;
		}

		if (destination.droppableId === source.droppableId &&
			destination.index === source.index) {
			return;
		}

		const column = this.state.initialData.columns[source.droppableId];
		const newTaskIds = Array.from(column.tasksIds);

		newTaskIds.splice(source.index, 1);
		newTaskIds.splice(destination.index, 0, draggableId);

		const newColumn = {
			...column,
			tasksIds: newTaskIds,
		};
		const newData = {
			...this.state.initialData,
			columns: {
				...this.state.initialData.columns,
				[newColumn.id]: newColumn,
			},
		};

		this.setState({initialData: newData});

	};

	render() {


		return (
			<React.Fragment>
				<Container className='tableContainer'>
					<Segment color='orange' loading={this.state.loading} >
						<Grid columns='equal' stackable>
							<Grid.Column>
								<h3>My Application</h3>
							</Grid.Column>
							<Grid.Column textAlign='center'>
								<p>*Drag and Drop according with your preferences*</p>
							</Grid.Column>
							<Grid.Column textAlign='right'>
								<Button
									icon='save'
									color='orange'
									labelPosition='left'
									size='small'
									content='Save'
									onClick={() => this.handleSave()}
								/>
							</Grid.Column>
						</Grid>

						<Message
							warning
							hidden={!this.state.warning}
							header='Warning'
							content="You don't have an application yet"
						/>
						<Message
							negative
							hidden={!this.state.error.visible}
							header='Error'
							content={this.state.error.message}
						/>
						<Message
							positive
							hidden={!this.state.success}
							header='Application Saved'
							content={'Your Application was successfully saved'}
						/>

						<DragDropContext onDragEnd={this.onDragEnd}>
							{this.state.initialData.columnOrder.map(columnId => {
								return (
									<Column
										key={columnId}
										column={this.state.initialData.columns[columnId]}
										tasks={this.state.initialData.columns[columnId].tasksIds.map(taskId => this.state.initialData.tasks[taskId])}
									/>);
							})
							}
						</DragDropContext>
					</Segment>
				</Container>
			</React.Fragment>
		);
	}
}

export default Application;
