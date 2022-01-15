######################################## first architecture

module "creativelighttp-1" {
  source = "./modules/creativelighttp"
  creativelighttp_name = "first"
  
}

######################################## second architecture

module "creativelighttp-2" {
  source = "./modules/creativelighttp"
  creativelighttp_name = "second"
}

######################################## third architecture

module "creativelighttp-3" {
  source = "./modules/creativelighttp"
  creativelighttp_name = "third"
  
}

######################################## outputs for each architecture

output "first-url" {
  value = module.creativelighttp-1.creativelighttp-url
}

output "second-url" {
  value = module.creativelighttp-2.creativelighttp-url
}

output "third-url" {
  value = module.creativelighttp-3.creativelighttp-url
}