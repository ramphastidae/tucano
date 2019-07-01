import React from 'react';
import ListItems from '../Shared/ListItems';

class Managers extends React.Component {
	render() {
		return (
			<ListItems
				kind='Manager'
				api='/v1/managers'
				add
				fields={{
					email: 'Email',
					name: 'Name',
					status: 'State'
				}}
				{...this.props}
			/>
		);
	}
}

export default Managers;
