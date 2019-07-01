import React from 'react';
import ListItems from "../Shared/ListItems";

class Users extends React.Component {

	constructor(props) {
		super(props);

		this.handleClickUser = this.handleClickUser.bind(this);
	}

	handleClickUser(id) {
		this.props.history.push(this.props.location.pathname + '/' + id + '/edit');
	};

	render() {
		const userRenderBodyRow = ({attributes, id}, i) => ({
			key: attributes.slug || `row-${i}`,
			onClick: () => this.handleClickUser(id),
			cells: [
				{key: 'uniNumber', content: attributes.uniNumber || 'No slug specified'},
				{key: 'name', content: attributes.name || 'No name specified'},
				{key: 'email', content: attributes.email || 'None'},
				{key: 'score', content: attributes.score.toFixed(3)|| 'None'},
				{key: 'group', content: attributes.group || 'None'},
			],
		});

		return (
			<ListItems
				kind="User"
				api="/v1/applicants"
				add
				deleteAll
				headers={{tenant: this.props.match.params.id}}
				fields={{
					uniNumber: 'Number',
					name: 'Name',
					email: 'Email',
					score: 'Score',
					group: 'Group'
				}}
				renderBodyRow={userRenderBodyRow}
				{...this.props}
			/>
		);
	}
}

export default Users;
