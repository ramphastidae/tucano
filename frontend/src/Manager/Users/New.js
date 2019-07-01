import React from 'react';
import {Button, Container, Form, Grid, Message, Progress, Segment} from 'semantic-ui-react';
import {handleError, handleChange, tupi} from '../../Shared/Helpers';

class NewUsers extends React.Component {
	constructor(props) {
		super(props);

		this.state = {
			id: '',
			name: '',
			email: '',
			group: '',
			score: '',
			fileReader: new FileReader(),
			errorFile: false,
			content: null,
			totalLoaded: 1,
			current: 1,
			contest: '',
			loading: false,
			success: false,
			error: {
				visible: false,
				message: ''
			}
		};

		this.handleChange = handleChange.bind(this);
		this.handleError = handleError.bind(this);
		this.handleSuccess = this.handleSuccess.bind(this);
		this.handleCreate = this.handleCreate.bind(this);
		this.handleCreateAll = this.handleCreateAll.bind(this);
		this.handleLoad = this.handleLoad.bind(this);
		this.handleOnChangeFile = this.handleOnChangeFile.bind(this);
		this.handleFileRead = this.handleFileRead.bind(this);
	}

	componentDidMount() {
		document.title = 'Tucano - Add New User';
		this.setState({contest: this.props.match.params.id});
	}

	changeUser() {
		if (this.state.current === this.state.totalLoaded) {
			// cleanup
			this.setState({id: '',
				name: '',
				email: '',
				group: '',
				score: '',
				totalLoaded: 1,
				current: 1,
				success: true,
				error: {visible: false, message: ''}
			});
			window.setTimeout(() => {
				this.setState({
					success: false
				});
			}, 5000);
		} else {
			this.setState({current: this.state.current + 1, error: {visible: false, message: ''}});
			this.setBoxesContent(this.state.current);
		}
	}

	verifyContent() {
		return this.state.id !== '' &&
			this.state.name !== '' &&
			this.state.email !== '' &&
			this.state.score !== ''
	}

	async handleCreate(event) {
		let score = parseFloat(this.state.score);

		if (this.verifyContent() && !isNaN(score)) {
			await tupi(
				'post',
				'/v1/applicants',
				this.handleSuccess,
				this.handleError,
				{
					'data': {
					attributes: {
						group: this.state.group,
						score: score + 0.00001,
						uni_number: this.state.id,
						user: {
							email: this.state.email,
							name: this.state.name
						}
					},
						type: 'applicants'
					}
				},
				{'tenant': this.state.contest}
			);
		} else if(isNaN(score)) {
			let error = {visible: true, message: 'Invalid score value.'};
			this.setState({error: error});
		}
		else {
			let error = {visible: true, message: 'Please fill all required fields'};
			this.setState({error: error});
		}
	}

	async handleSuccess(res) {
		await this.changeUser();
	}

	async handleCreateAll(event) {
		this.setState({loading: true});
		for (let i = this.state.current; i <= this.state.totalLoaded; i++) {
			await this.handleCreate();
			if(this.state.error.visible || this.state.errorFile){
				break;
			}
		}
		this.setState({loading: false});
	};

	handleLoad() {
		//Opens de Upload Window
		this.refs.fileUploader.click();
	};

	setBoxesContent(current) {
		current--;
		const jsonObject = this.state.content;
		this.setState({
			id: jsonObject.users[current].id || '',
			name: jsonObject.users[current].name || '',
			email: jsonObject.users[current].email || '',
			group: jsonObject.users[current].group || '',
			score: jsonObject.users[current].score || ''
		});
	}

	handleFileRead() {
		try {
			const content = this.state.fileReader.result;
			const jsonObject = JSON.parse(content);

			this.setState({
				totalLoaded: jsonObject.users.length,
				errorFile: false,
				content: jsonObject,
				current: 1
			});

			this.setBoxesContent(1);
		} catch (e) {
			this.setState({errorFile: true});
		}

	};

	handleOnChangeFile(event) {
		event.stopPropagation();
		event.preventDefault();

		if (event.target.files[0]) {
			let fr = this.state.fileReader;
			fr.onloadend = this.handleFileRead;
			this.setState({fileReader: fr});
			this.state.fileReader.readAsText(event.target.files[0]);
		}

		event.target.value = null;
	};

	render() {
		return (
			<div>
				<Container className='tableContainer'>
					<Segment color='orange' loading={this.state.loading}>
						<Grid columns='equal' stackable>
							<Grid.Column>
								<h3>Add New User</h3>
							</Grid.Column>
							<Grid.Column textAlign='right'>
								<input
									type='file'
									id='file'
									ref='fileUploader'
									style={{display: 'none'}}
									onChange={this.handleOnChangeFile}
								/>
								<Button
									icon='upload'
									color='orange'
									labelPosition='left'
									size='small'
									onClick={this.handleLoad}
									content='Upload JSON'
								/>
							</Grid.Column>
						</Grid>
						<Message
							hidden={!this.state.errorFile}
							negative
							header='Uploading Users info failed'
							content='File is badly constructed'
						/>
						<p/>
						<Form>
							<Form.Input
								required={true}
								label='Id Code'
								name='id'
								value={this.state.id}
								onChange={this.handleChange}
							/>
							<Form.Input
								required={true}
								label='Name'
								name='name'
								value={this.state.name}
								onChange={this.handleChange}
							/>
							<Form.Input
								required={true}
								label='Email'
								name='email'
								value={this.state.email}
								onChange={this.handleChange}
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
						</Form>
						<p/>
						<Message
							visible={!this.state.success}
							hidden={!this.state.success}
							success
							header='User(s) Created'
							content='New User(s) created with success'
						/>
						<Message
							hidden={!this.state.error.visible}
							negative
							header='Creation of User(s) failed'
							content={this.state.error.message}
						/>
						<Grid columns='equal' stackable>
							<Grid.Column>
								<Button
									icon='add'
									labelPosition='left'
									color='orange'
									size='large'
									onClick={this.handleCreate}
									content='Add User'
								/>
							</Grid.Column>
							<Grid.Column>
								<Progress
									value={this.state.current}
									total={this.state.totalLoaded}
									size='medium'
									label={'Progress: ' + this.state.current + '/' + this.state.totalLoaded}
								/>
							</Grid.Column>
							<Grid.Column textAlign='right'>
								<Button
									disabled={this.state.totalLoaded === 1}
									icon='forward'
									labelPosition='right'
									color='orange'
									size='large'
									onClick={this.handleCreateAll}
									content='Add All'
								/>
							</Grid.Column>
						</Grid>
					</Segment>
				</Container>
			</div>
		);
	}
}

export default NewUsers;
