using GrowFlow.Api.Compliance.Service;
using GrowFlow.Model;
using GrowFlow.Model.Persistance;
using GrowFlow.Web.Attributes; 
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Threading.Tasks;
using System.Web.Http;
using GrowFlow.Model.Organization;
using GrowFlow.Web.DTO.Admin;

namespace GrowFlow.Web.WebAPI
{
    [AuthorizeUserApi]
    [Route("Products")]
    public partial class AdminController : GrowFlowApiController
    {
        // GET: AdminControllerProduct
        [HttpGet]
        [Route("Products")]
        public List<Product> GetProduct(int accountId)
        {
            using (var dbContext = new GrowFlowContext())
            {
                using (var service = ComplianceService.Create(dbContext, account))
                {
                    var Products = dbContext.Products.Where(s => s.AccountId == account.Id);

                    return Products.ToList();
                }
            }
        }

        [HttpPost]
        [Route("Products")]
        public async Task<CreateOperationResult> CreateProduct(Product Product)
        {
            using (var dbContext = new GrowFlowContext())
            {
                using (var service = ComplianceService.Create(dbContext, account))
                {
                    try
                    {
                        var getProduct = dbContext.Products.FirstOrDefault(s => s.AccountId == account.Id && s.Name.ToLower() == Product.Name.ToLower());
                        if (getProduct == null)
                        {
                            Product.AccountId = account.Id;
                            
                            dbContext.Products.Add(Product);

                            dbContext.SaveChanges();
                        }
                        return new CreateOperationResult()
                        {
                            Success = true,
                            Data = Product
                        };
                    }
                    catch (Exception e)
                    {
                        return new CreateOperationResult()
                        {
                            Success = false,
                            Exception = e.Message
                        };
                    }
                }
            }
        }

        [HttpPut]
        [Route("Products")]
        public async Task<CreateOperationResult> EditProduct(int ProductId, Product Product)
        {
            using (var dbContext = new GrowFlowContext())
            {
                using (var service = ComplianceService.Create(dbContext, account))
                {
                    Product facility = dbContext.Set<Product>().AsNoTracking()
                        .FirstOrDefault(s => s.AccountId == account.Id && s.Id == ProductId);

                    if (facility == null)
                    {
                        return new CreateOperationResult()
                        {
                            Success = false,
                            Exception = "Unable to edit Product.  No facility location exists for this account."
                        };
                    }

                    try
                    {
                        // Product.Daysinflower = .Daysinflower;

                        dbContext.Products.Attach(Product);

                        var entry = dbContext.Entry(Product);
                        entry.State = EntityState.Modified;

                        dbContext.SaveChanges();

                        return new CreateOperationResult()
                        {
                            Success = true,
                            Data = Product
                        };
                    }
                    catch (Exception e)
                    {
                        return new CreateOperationResult()
                        {
                            Success = false,
                            Exception = e.Message
                        };
                    }
                }
            }
        }

        [HttpGet]
        [Route("Products/{id:int}/IsDeletable")]
        public DeletableDTO IsProductDeletable(int id)
        {
            using (var dbContext = new GrowFlowContext())
            {
                using (var service = ComplianceService.Create(dbContext, account))
                {
                   // bool isDeletable = service.DoesProductContainInventory(account, ProductId);

                    return new DeletableDTO
                    {
                        IsDeletable = false,
                        Message = "Please remove all inventory from this Product before deleting."
                    };
                }
            }
        }

        [HttpDelete]
        [Route("Products/{id:int}")]
        public async Task<OperationResult> DeleteProduct(int id)
        {
            using (var dbContext = new GrowFlowContext())
            {
                using (var service = ComplianceService.Create(dbContext, account))
                {
                    try
                    {
                        var Product = dbContext.Products.Single(s => s.Id == id && s.AccountId == account.Id);
                        dbContext.Products.Attach(Product);
                        dbContext.Products.Remove(Product);
                        dbContext.SaveChanges();

                        return new CreateOperationResult()
                        {
                            Success = true
                        };
                    }
                    catch (Exception e)
                    {
                        return new CreateOperationResult()
                        {
                            Success = false,
                            Exception = e.Message
                        };
                    }
                }
            }
        }
    }
}