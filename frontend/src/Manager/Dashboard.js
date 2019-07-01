import React from 'react';
import XLSX from 'xlsx';
import {Button, Container, Grid, Label, Message, Segment} from 'semantic-ui-react';
import {handleError, handleChange, tupi} from '../Shared/Helpers.js';
import ListItems from "../Shared/ListItems";

class Dashboard extends React.Component {
	constructor(props) {
		super(props);

		this.state = {
			contest: '',
			name: '',
			slug: '',
			begin: '',
			end: '',
			id: '',
			unmediated: {},
			unplaced: {},
			active: false,
			loading: false,
			success: false,
			error: {
				visible: false,
				message: ''
			}
		};

		this.handleChange = handleChange.bind(this);
		this.handleError = handleError.bind(this);
		this.handleContest = this.handleContest.bind(this);
		this.handleClickItem = this.handleClickItem.bind(this);
		this.handleSuccess = this.handleSuccess.bind(this);
		this.handleExportCSVSuccess = this.handleExportCSVSuccess.bind(this);
		this.handleExportExcelSuccess = this.handleExportExcelSuccess.bind(this);
		this.handleUnplacedSuccess = this.handleUnplacedSuccess.bind(this);
		this.handleUnmediatedSuccess = this.handleUnmediatedSuccess.bind(this);
	}

	componentWillMount() {
		document.title = 'Tucano - Contest Dashboard';

		this.setState({contest: this.props.match.params.id, loading: true});

		tupi(
			'get',
			'/v1/contests/' + this.props.match.params.id,
			this.handleContest,
			this.handleError,
			null,
			{'tenant': this.props.match.params.id}
		);
	}

	handleContest(res) {
		if (res && res.hasOwnProperty('data') && res.data.hasOwnProperty('data')) {
			const attributes = res.data.data.attributes;

			this.setState({
				name: attributes.name,
				slug: attributes.slug,
				begin: attributes.begin.split('T')[0],
				end: attributes.end.split('T')[0],
				id: res.data.data.id,
				active: new Date(attributes.end.split('T')[0]).setHours(0,0,0,0)
							>= new Date().setHours(0,0,0,0)
					&& new Date(attributes.begin.split('T')[0]).setHours(0,0,0,0)
							<= new Date().setHours(0,0,0,0),
				loading: false
			});
		}
	}

	handleEditDates() {
		this.props.history.push('/manager/contests/' + this.props.match.params.id + '/dates/edit');
	}

	handleUnplacedSuccess(data) {
		this.setState({unplaced: data});
	}

	handleUnmediatedSuccess(data) {
		this.setState({unmediated: data});
	}

	async handleExportCSV() {
		//get unplaced
		await tupi(
			'get',
			'/v1/unplaced',
			this.handleUnplacedSuccess,
			this.handleError,
			null,
			{'tenant': this.props.match.params.id}
		);

		//get unmediated
		await tupi(
			'get',
			'/v1/unmediated',
			this.handleUnmediatedSuccess,
			this.handleError,
			null,
			{'tenant': this.props.match.params.id}
		);

		//get results
		await tupi(
			'get',
			'/v1/results',
			this.handleExportCSVSuccess,
			this.handleError,
			null,
			{'tenant': this.props.match.params.id}
		);
	}

	handleExportCSVSuccess(data) {
		var subjects = data.data.data,
			settings = data.data.included.filter(e => e.type === 'settings'),
			applicants = data.data.included.filter(e => e.type === 'applicants');

		var csv = 'Number,Name,Group,Subject,Subject_Group,Status\n';

		// results
		// eslint-disable-next-line array-callback-return
		subjects.map(subject => {
			var setting = settings.filter(e => e.id === subject.relationships.setting.data.id)[0],
				applicantsIds = subject.relationships.applicants.data.map(e => e.id),
				applicantsInSubject = applicants.filter(e => applicantsIds.includes(e.id));

			applicantsInSubject.map(applicant =>
				csv += applicant.attributes.uniNumber + ','
					+ applicant.attributes.name + ','
					+ applicant.attributes.group + ','
					+ subject.attributes.name + ' (' + subject.attributes.code + '),'
					+ setting.attributes.typeKey + ','
					+ 'Placed\n');
		});

		// unplaced
		this.state.unplaced.data.data.map(applicant =>
			csv += applicant.attributes.uniNumber + ','
				+ applicant.attributes.name + ','
				+ applicant.attributes.group + ','
				+ '-,'
				+ '-,'
				+ 'Unplaced\n');

		// unmediated
		this.state.unmediated.data.data.map(applicant =>
			csv += applicant.attributes.uniNumber + ','
				+ applicant.attributes.name + ','
				+ applicant.attributes.group + ','
				+ '-,'
				+ '-,'
				+ 'Without Application\n');

		var hiddenElement = document.createElement('a');
		hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
		hiddenElement.target = '_blank';
		hiddenElement.download = 'result_' + new Date().toJSON() + '.csv';
		hiddenElement.click();
	}

	async handleExportExcel() {
		//get unplaced
		await tupi(
			'get',
			'/v1/unplaced',
			this.handleUnplacedSuccess,
			this.handleError,
			null,
			{'tenant': this.props.match.params.id}
		);

		//get unmediated
		await tupi(
			'get',
			'/v1/unmediated',
			this.handleUnmediatedSuccess,
			this.handleError,
			null,
			{'tenant': this.props.match.params.id}
		);

		//get results
		await tupi(
			'get',
			'/v1/results',
			this.handleExportExcelSuccess,
			this.handleError,
			null,
			{'tenant': this.props.match.params.id}
		);
	}

	handleExportExcelSuccess(data) {

		let subjects = data.data.data,
			applicants = data.data.included.filter(e => e.type === 'applicants');

		let wb = XLSX.utils.book_new();

		// results
		// eslint-disable-next-line array-callback-return
		subjects.map(subject => {
			let table = document.createElement('table'),
				html = '<thead><tr><th>Number</th><th>Name</th><th>Group</th></tr></thead><tbody>',
				applicantsIds = subject.relationships.applicants.data.map(e => e.id),
				applicantsInSubject = applicants.filter(e => applicantsIds.includes(e.id));

			applicantsInSubject.map(applicant =>
				html += '<tr><td>' + applicant.attributes.uniNumber + '</td><th>'
					+ applicant.attributes.name + '</th><th>'
					+ applicant.attributes.group + '</th></tr>');

			table.innerHTML = html + '</tbody>';
			let sheet = XLSX.utils.table_to_sheet(table);
			XLSX.utils.book_append_sheet(wb, sheet, subject.attributes.code);
		});

		// unplaced
		let table = document.createElement('table'),
			html = '<thead><tr><th>Number</th><th>Name</th><th>Group</th></tr></thead><tbody>';
		// eslint-disable-next-line array-callback-return
		this.state.unplaced.data.data.map(applicant => {
			html += '<tr><td>' + applicant.attributes.uniNumber + '</td><th>'
				+ applicant.attributes.name + '</th><th>'
				+ applicant.attributes.group + '</th></tr>';
		});
		table.innerHTML = html + '</tbody>';
		let sheet = XLSX.utils.table_to_sheet(table);
		XLSX.utils.book_append_sheet(wb, sheet, 'Unplaced');

		// unmediated
		table = document.createElement('table');
		html = '<thead><tr><th>Number</th><th>Name</th><th>Group</th></tr></thead><tbody>';
		// eslint-disable-next-line array-callback-return
		this.state.unmediated.data.data.map(applicant => {
			html += '<tr><td>' + applicant.attributes.uniNumber + '</td><th>'
				+ applicant.attributes.name + '</th><th>'
				+ applicant.attributes.group + '</th></tr>';
		});
		table.innerHTML = html + '</tbody>';
		sheet = XLSX.utils.table_to_sheet(table);
		XLSX.utils.book_append_sheet(wb, sheet, 'Without Application');

		return XLSX.writeFile(wb, 'result_' + new Date().toJSON() + '.xlsx');
	}

	handleRunApplication(){
		tupi(
			'post',
			'/v1/contests/' + this.props.match.params.id + '/mediator',
			this.handleSuccess,
			this.handleError,
			null,
			{'tenant': this.props.match.params.id}
		);
	}

	handlePublishResults(){
		this.props.history.push('/manager/contests/' + this.props.match.params.id + '/publish-results');
	}

	handleSuccess() {
		let error = {visible: false, message: ''};
		this.setState({success: true, error: error});
		window.setTimeout(() => {
			this.setState({
				success: false
			});
		}, 5000);
	}

	handleClickItem(id) {
		this.props.history.push('/manager/contests/' + this.props.match.params.id + '/users/' + id + '/edit');
	};

	treatIncludedData(included, data) {
		for(let i=0; i<data.length; i++) {
			for(let j=0; j<included.length; j++) {
				if(data[i].relationships.applicant.data.id === included[j].id) {
					data[i].attributes['uniNumber'] = included[j].attributes.uniNumber;
				}
			}
		}
		return data;
	}

	handleDelete() {
		this.props.history.push('/manager/contests/' + this.props.match.params.id + '/confirm-delete');
	}

	render() {
		const problemRenderBodyRow = ({attributes, relationships}, id) => ({
			key: id || `row-${id}`,
			onClick: () => this.handleClickItem(relationships.applicant.data.id),
			cells: [
				{key: 'user', content: attributes.uniNumber || 'No user specified'},
				{key: 'description', content: attributes.description || 'No description specified'},
				{key: 'status', content: attributes.status || 'No status specified'}
			],
		});
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
						<Message
							positive
							hidden={!this.state.success}
							header='Success'
							content='Your action was completed with success'
						/>
						<Grid stackable>
							<Grid.Row columns='equal'>
								<Grid.Column>
									<h3>{this.state.contest}</h3>
								</Grid.Column>
								<Grid.Column textAlign='right'>
									<Label color='orange' tag={true} size='large'>
										STATUS: {this.state.active ? 'ACTIVE' : 'INACTIVE'}
									</Label>
									<Button
										basic
										color='orange'
										icon='trash alternate'
										size='small'
										onClick={() => this.handleDelete()}
									/>
								</Grid.Column>
							</Grid.Row>
							<Grid.Row columns='equal'>
								<Grid.Column stretched>
									<Segment color='black'>
										<h5>CONTEST PERIOD</h5>
										<p>
											<b>Start Date:</b> {this.state.begin} <br/>
											<b>End Date:</b> {this.state.end}
										</p>
										<Button
											disabled={
												new Date(this.state.begin).setHours(0,0,0,0)
													<= new Date().setHours(0,0,0,0)}
											fluid={true}
											basic
											icon='calendar alternate outline'
											labelPosition='left'
											size='small'
											onClick={() => this.handleEditDates()}
											content='Edit'
										/>
									</Segment>
								</Grid.Column>
								<Grid.Column stretched>
									<Segment color='black'>
										<h5>Manage Application</h5>
										<Button
											disabled={(new Date(this.state.end).setHours(0,0,0,0)
												>= new Date().setHours(0,0,0,0))}
											fluid={true}
											basic
											icon='play'
											labelPosition='left'
											size='small'
											onClick={() => this.handleRunApplication()}
											content='Run Application'
										/>
										<p/>
										<Button
											disabled={(new Date(this.state.end).setHours(0,0,0,0)
												>= new Date().setHours(0,0,0,0))}
											fluid={true}
											basic
											icon='share square'
											labelPosition='left'
											size='small'
											onClick={() => this.handlePublishResults()}
											content='Publish Results'
										/>
									</Segment>
								</Grid.Column>
								<Grid.Column stretched>
									<Segment color='black'>
										<h5>Export Results</h5>
										<Button
											fluid={true}
											disabled={(new Date(this.state.end).setHours(0,0,0,0)
												>= new Date().setHours(0,0,0,0))}
											basic
											icon='file excel outline'
											labelPosition='left'
											size='small'
											onClick={() => this.handleExportExcel()}
											content='Excel File'
										/>
										<p/>
										<Button
											fluid={true}
											disabled={(new Date(this.state.end).setHours(0,0,0,0)
												>= new Date().setHours(0,0,0,0))}
											basic
											icon='file alternate outline'
											labelPosition='left'
											size='small'
											onClick={() => this.handleExportCSV()}
											content='CSV File'
										/>
									</Segment>
								</Grid.Column>
							</Grid.Row>
						</Grid>
					</Segment>
					<ListItems
						kind="Problem"
						api="/v1/incoherences"
						headers={{tenant: this.props.match.params.id}}
						fields={{
							uniNumber: 'User',
							description: 'Description',
							status: 'Status'
						}}
						renderBodyRow={problemRenderBodyRow}
						included={this.treatIncludedData}
						{...this.props}
					/>
				</Container>
			</React.Fragment>
		);
	}
}

export default Dashboard;
