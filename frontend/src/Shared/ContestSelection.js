import React from 'react';
import ListItems from "./ListItems";

class ContestSelection extends React.Component {

	constructor(props) {
		super(props);

		this.handleClickContest = this.handleClickContest.bind(this);
	}

	handleClickContest(id) {
		this.props.history.push(this.props.location.pathname + '/' + id);
	};

	treatIncludedData(included, data) {
		for(let i=0; i<data.length; i++) {
			 if (new Date(data[i].attributes.end.split('T')[0]).setHours(0,0,0,0)
				>= new Date().setHours(0,0,0,0)
				&& new Date(data[i].attributes.begin.split('T')[0]).setHours(0,0,0,0)
				<= new Date().setHours(0,0,0,0) ) {
				 data[i].attributes['status'] = 'Active';
			 }
			 else {
				 data[i].attributes['status'] = 'Inactive';
			 }
		}
		return data;
	}

	render() {
		const contestRenderBodyRow = ({attributes}, i) => ({
			key: attributes.slug || `row-${i}`,
			onClick: () => this.handleClickContest(attributes.slug),
			cells: [
				{key: 'slug', content: attributes.slug || 'No slug specified'},
				{key: 'name', content: attributes.name || 'No name specified'},
				{key: 'begin', content: attributes.begin.split('T')[0] || 'None'},
				{key: 'end', content: attributes.end.split('T')[0] || 'None'},
				(attributes.status === 'Active') ?
					{key: 'status', icon: 'check circle', content: 'Active'} :
					{key: 'status', icon: 'times circle', content: 'Inactive'},
			],
		});

		return (
			<ListItems
				kind="Contest"
				api="/v1/contests"
				add={(localStorage.getItem('usertype') === 'manager')}
				fields={{
					slug: 'Id',
					name: 'Description',
					begin: 'Start',
					end: 'End',
					status: 'Status',
				}}
				renderBodyRow={contestRenderBodyRow}
				included={this.treatIncludedData}
				{...this.props}
			/>
		);
	}
}

export default ContestSelection;
