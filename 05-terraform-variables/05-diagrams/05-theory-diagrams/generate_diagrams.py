from diagrams import Diagram, Cluster
from diagrams.onprem.iac import Terraform
from diagrams.aws.general import General
from diagrams.programming.language import Python
from diagrams.aws.management import Config

def create_variables_diagram():
    graph_attr = {
        "pad": "1.5",
        "splines": "ortho",
        "nodesep": "1.0",
        "rankdir": "LR"
    }
    
    with Diagram(
        "Terraform Variables Concept",
        show=True,
        filename="terraform_variables_concept",
        graph_attr=graph_attr,
        outformat="png"
    ):
        with Cluster("Terraform Configuration"):
            tf = Terraform("Terraform")
            
            with Cluster("Variable Types"):
                input_vars = General("Input Variables")
                local_vars = General("Local Variables")
                output_vars = General("Output Variables")
            
            with Cluster("Data Sources"):
                data = Config("Data Sources")
            
            # Define relationships
            tf >> input_vars
            tf >> local_vars
            tf >> output_vars
            tf >> data

if __name__ == "__main__":
    try:
        create_variables_diagram()
        print("Diagram created successfully!")
    except Exception as e:
        print(f"Error creating diagram: {str(e)}") 