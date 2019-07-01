import React from 'react';
import ConfirmPage from "../../Shared/ConfirmPage";

class ConfirmContestDelete extends React.Component {
	render() {
		return (
			<ConfirmPage
				kind='delete contest'
				api={'/v1/contests/' + this.props.match.params.id}
				method='delete'
				return='/manager/contests'
				headers={{tenant: this.props.match.params.id}}
				{...this.props}
			/>
		);
	}
}

export default ConfirmContestDelete;
