#!groovy
pipeline {
  agent any
  tools {
    terraform 'terraform-v1.1.4'
  }
  parameters {
    //Terraform crea un cluster regional. Selecciona las zonas para agregar alta disponibilidad.
    booleanParam defaultValue: false, description: 'Click para crear un cluster', name: 'crea_cluster'
    booleanParam defaultValue: true, description: 'Por defecto la region us-west2-a esta asignada', name: 'zone_a'
    booleanParam defaultValue: false, description: 'Agrega region us-west2-b', name: 'zone_b'
    booleanParam defaultValue: false, description: 'Agrega region us-west2-c', name: 'zone_c'
  }
  triggers {
        gitlab(triggerOnPush: true, triggerOnMergeRequest: true, branchFilterType:'NameBasedFilter',includeBranchesSpec: "main",excludeBranchesSpec: "")
        cron('@midnight')
  }

  stages {
    stage('Terraform deploy or destroy') {
      environment {
        GET_ZONES = getZones()
        TF_VAR_cluster_node_locations = "${GET_ZONES}"
      }
      steps {
        script {
          tf_exec()
        }
      }
    }
  }

  post {
    always {
      echo 'Limpiando espacio de trabajo.'
      cleanWs(
        cleanWhenNotBuilt: false,
        deleteDirs: true,
        disableDeferredWipeout: true,
        notFailBuild: true
        )
      }
      success {
        echo 'Finalizado con exito'
      }
      unstable {
        echo 'Algun paso del pipeline ha fallado.'
      }
      failure {
        echo 'El pipeline ha fallado.'
      }
      aborted {
        echo 'Algo ha cambiado en el repositorio.'
      }
    }
  }

def tf_exec() {
  withCredentials([file(credentialsId: 'your-sa-with-permissions', variable: 'GOOGLE_CREDENTIALS')]) {
  sh 'terraform init  -no-color'
  if (params.crea_cluster == true) {
    sh 'terraform plan -no-color -var-file=main.tfvars -out plan.out'
    def userInput = input(id: 'confirm', message: 'Apply Terraform?', parameters: [ [$class: 'BooleanParameterDefinition', defaultValue: false, description: 'Apply terraform', name: 'confirm'] ])
  }
  if (params.crea_cluster == false) {
    sh 'terraform plan  -no-color -destroy -var-file=main.tfvars -out plan.out'
   }
  sh 'terraform apply -no-color -input=false plan.out'
  }
}

def getZones() {
  def zone_a = params.zone_a ? "us-west2-a" : ""
  def zone_b = params.zone_b == true ? ",us-west2-b" : ""
  def zone_c = params.zone_c == true ? ",us-west2-c" : ""
  return zone_a + zone_b + zone_c 
}

