import React from 'react';
import {
	Button,
	Container,
	Dropdown,
	Grid,
	Icon,
	Input,
	Message,
	Segment,
	Table
} from 'semantic-ui-react';
import './ListItems.css';
import {handleChange, handleError, tupi} from '../Shared/Helpers';


class ListItems extends React.Component {
    constructor(props) {
        super(props);

        this.state = {
            items: [],
			direction: null,
			sortedCol: null,
			allitems: [],
            error: {
            	visible: false,
				message: ''
			},
            loading: false,
			column: '',
			input: ''
        };

		this.handleClickItem = this.handleClickItem.bind(this);
        this.handleItems = this.handleItems.bind(this);
        this.handleColumnChange = this.handleColumnChange.bind(this);
        this.handleSearch = this.handleSearch.bind(this);
        this.handleChange = handleChange.bind(this);
        this.handleError = handleError.bind(this);
		this.handleSort = this.handleSort.bind(this);
    }

    componentWillMount() {
        document.title = 'Tucano - ' + this.props.kind + ' List';

        this.setState({loading: true});

        tupi(
            'get',
            this.props.api,
            this.handleItems,
            this.handleError,
            null,
            this.props.headers
        );
    }

    handleItems(res) {
        if (res && res.hasOwnProperty('data') && res.data.hasOwnProperty('data')) {
        	let items = res.data.data;
			if(this.props.hasOwnProperty('included')) {
				items = this.props.included(res.data.included, res.data.data);
			}
			this.setState({items: items, allitems: items, loading: false});
        }
    }

    handleAddItem() {
    	let route = '/new';
		if(this.props.hasOwnProperty('extraRoute')) {
			route = this.props.extraRoute + route;
		}
        this.props.history.push(this.props.location.pathname + route);
    }

    handleSearch() {
		let allitems = this.state.allitems,
			input = this.state.input,
			column = this.state.column;

		if (input.lenght !== 0 && column.length !== 0) {
			this.setState({items: allitems.filter(e => e.attributes[column].toString().match(input))});
		} else {
			this.setState({items: allitems});
		}
	}

	handleClickItem(id) {
    	let route = '/' + id + '/edit';
		if(this.props.hasOwnProperty('extraRoute')) {
			route = this.props.extraRoute + route;
		}
		this.props.history.push(this.props.location.pathname + route);
	}

	handleDeleteAll() {
        this.props.history.push(this.props.location.pathname + '/delete/all');
    }

	handleColumnChange(event, e) {
		this.setState({column: e.value});
	}

	handleSort(clickedColumn) {
		const sortBy = (key) => {
			return (a, b) => (a.attributes[key] > b.attributes[key]) ? 1 : ((b.attributes[key] > a.attributes[key]) ? -1 : 0);
		};

		const {sortedCol, items, direction} = this.state;

		if (sortedCol !== clickedColumn) {
			this.setState({
				sortedCol: clickedColumn,
				items: items.concat().sort(sortBy(clickedColumn)),
				direction: 'ascending',
			});
			return;
		}

		this.setState({
			items: items.reverse(),
			direction: direction === 'ascending' ? 'descending' : 'ascending',
		});
	}

    render() {
		//header
		const {sortedCol, direction} = this.state;
		const fields = this.props.fields;
		const handleSort = this.handleSort;
		const headerRow = Object.keys(this.props.fields).map(k => (
			<Table.HeaderCell
				key={k}
				sorted={sortedCol === k ? direction : null}
				onClick={() => handleSort(k)}>
				{fields[k]}
			</Table.HeaderCell>
		));

		//body
        const renderBodyRow = ({attributes, id}, i) => ({
            key: id || `row-${i}`,
            cells: Object.keys(this.props.fields).map(e => attributes[e] || 'No ' + e + ' specified'),
			onClick: () => this.handleClickItem(id)
        });

        return (
            <React.Fragment>
                <Container className='tableContainer'>
                    <Segment color='orange' loading={this.state.loading}>
                        <Grid columns='equal' stackable>
							<Grid.Row>
                            	<Grid.Column>
                                	<h3>{this.props.kind} List</h3>
                            	</Grid.Column>
                            	<Grid.Column textAlign='right'>
									{(this.props.hasOwnProperty('deleteAll') && this.props.deleteAll !== false) ?
                                    	<Button
                                        	basic
                                        	icon
                                        	color='orange'
                                        	labelPosition='left'
                                        	size='small'
                                        	onClick={() => this.handleDeleteAll()}
                                   	 	>
                                        	<Icon name='minus'/> Delete All
                                    	</Button>
                                    	:
                                    	""
                                	}
                                	{(this.props.hasOwnProperty('add') && this.props.add !== false) ?
                                    	<Button
                                        	icon
                                        	color='orange'
                                        	labelPosition='left'
                                        	size='small'
                                        	onClick={() => this.handleAddItem()}
                                    	>
                                        	<Icon name='add'/> Add {this.props.kind}
                                    	</Button>
                                    	:
                                    	""
                                	}
                            	</Grid.Column>
							</Grid.Row>
							<Grid.Row className={!this.state.items.length && !this.state.input.length ? 'hidden' : ''}>
								<Grid.Column>
									<Input
										required={true}
										placeholder='Search for'
										name='input'
										fluid
										value={this.state.input}
										onChange={this.handleChange}
									/>
								</Grid.Column>
								<Grid.Column>
									<Dropdown
										required={true}
										placeholder='In'
										name='column'
										clearable
										selection
										fluid
										value={this.state.column}
										onChange={this.handleColumnChange}
										options={Object.keys(this.props.fields).map(k => (
											{'key': k, 'value': k, 'text': this.props.fields[k]})
										)}
										/>
								</Grid.Column>
								<Grid.Column textAlign='right'>
									<Button
										fluid
										basic
										icon='search'
										color='orange'
										labelPosition='left'
										size='small'
										content='Search'
										onClick={() => this.handleSearch()}
									/>
								</Grid.Column>
							</Grid.Row>
                        </Grid>

                        <Message
                            negative
                            hidden={!this.state.error.visible}
                            header='Error'
                            content={this.state.error.message}
                        />

                        <Table
							hidden={!this.state.items.length}
							color='black'
							stackable
							selectable
							sortable
							fixed
							celled
							headerRow={headerRow}
							renderBodyRow={(this.props.hasOwnProperty('renderBodyRow')) ?
                                                this.props.renderBodyRow : renderBodyRow}
							tableData={this.state.items}
						/>

						<Message
							hidden={!!this.state.items.length}
							header='Empty List'
							content='There are no items to list.'
						/>
                    </Segment>
                </Container>
            </React.Fragment>
        );
    }
}

export default ListItems;
