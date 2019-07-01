import React from 'react';
import ConfirmPage from "../Shared/ConfirmPage";

class ConfirmPublish extends React.Component {
	render() {
		return (
			<ConfirmPage
				kind='publish results'
				api={'/v1/contests/' + this.props.match.params.id}
				method='patch'
				headers={{tenant: this.props.match.params.id}}
				data={{
					'data': {
						attributes: {
							status: 2
						},
						id: this.props.match.params.id,
						type: 'contests'
					}
				}}
				{...this.props}
			/>
		);
	}
}

export default ConfirmPublish;
