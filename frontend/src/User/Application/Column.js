import React from 'react'
import {Container, Divider, Segment} from "semantic-ui-react";
import Task from './Task.js';
import {Droppable} from 'react-beautiful-dnd';

class Column extends React.Component {

	render() {
		return (
			<Container>
				<Divider horizontal>
					<h3>{this.props.column.title}</h3>
				</Divider>
				<Segment>
					<Droppable droppableId={this.props.column.id}>
						{(provided) => (
							<div
								{...provided.droppableProps}
								ref={provided.innerRef}
							>
								{this.props.tasks.map((task, index) => (
									<Task
										key={task.id}
										task={task}
										index={index}
										size={Object.values(this.props.tasks).length}
									/>)
								)}
								{provided.placeholder}
							</div>
						)}
					</Droppable>
				</Segment>
			</Container>
		)
	}

}

export default Column;
