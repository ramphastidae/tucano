import React from 'react';
import {Draggable} from 'react-beautiful-dnd';
import {Divider, Grid, Label, List} from "semantic-ui-react";

class Task extends React.Component {
	render() {
		return (
			<Draggable draggableId={this.props.task.id} index={this.props.index}>
				{(provided) => (
					<div
						{...provided.draggableProps}
						{...provided.dragHandleProps}
						ref={provided.innerRef}
					>

						<List.Item>
							<Grid columns='equal' stackable>
								<Grid.Column width={1}>
									<Label basic color='orange'>
										{this.props.index + 1}
									</Label>
								</Grid.Column>
								<Grid.Column verticalAlign='middle'>
									<List.Content>
										<List.Header>{this.props.task.code}: {this.props.task.content} </List.Header>
										{(this.props.task.conflicts != null) ?
											<List.Description>
												Conflicts: {this.props.task.conflicts}
											</List.Description> : ""}
									</List.Content>
								</Grid.Column>
							</Grid>
						</List.Item>
						{this.props.size !== this.props.index + 1 ? <Divider/> : ""}
					</div>
				)}
			</Draggable>
		);
	}
}

export default Task;
