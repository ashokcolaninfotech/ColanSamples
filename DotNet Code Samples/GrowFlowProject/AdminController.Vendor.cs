using GrowFlow.Api.Compliance.Service;
using GrowFlow.Model;
using GrowFlow.Model.Persistance;
using GrowFlow.Web.Attributes;
using GrowFlow.Web.DTO.Admin;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Http;

namespace GrowFlow.Web.WebAPI
{
    [AuthorizeUserApi]
    public partial class AdminController : GrowFlowApiController
    {
        [HttpGet]
        [Route("FavoriteVendors")]
        public List<FavoriteVendorDTO> GetFavoriteVendors(int accountId)
        {
            List<FavoriteVendorDTO> FavoriteVendors = new List<FavoriteVendorDTO>();
            using (var dbContext = new GrowFlowContext())
            {
                using (var service = ComplianceService.Create(dbContext, account))
                {
                    FavoriteVendors = service.GetFavoriteVendors()
                        .Select(v => new FavoriteVendorDTO
                        {
                            Id = v.Id,
                            Notes = v.Notes,
                            VendorId = v.Vendor.Id
                        }).ToList();

                    return FavoriteVendors;
                }
            }
        }

        [HttpGet]
        [Route("Vendors")]
        public List<VendorDTO> GetVendors(int accountId)
        {
            List<VendorDTO> vendors = new List<VendorDTO>();
            using (var dbContext = new GrowFlowContext())
            {
                using (var service = ComplianceService.Create(dbContext, account))
                {
                    vendors = service.GetVendors()
                        .Select(v => new VendorDTO
                        {
                            Id = v.Id,
                            Name = v.Name,
                            Address = new AddressDTO()
                            {
                                Line1 = v.Address.Line1,
                                Line2 = v.Address.Line2,
                                Line3 = v.Address.Line3,
                                City = v.Address.City,
                                Country = v.Address.Country,
                                PostalCode = v.Address.PostalCode,
                                Region = v.Address.Region
                            },
                            Type = v.Type
                        }).ToList();

                     

                    return vendors;
                }
            }
        }

        [HttpPost]
        [Route("FavoriteVendor")]
        public CreateOperationResult CreateFavoriteVendor(FavoriteVendorDTO dto)
        {
            using (var dbContext = new GrowFlowContext())
            {
                using (var service = ComplianceService.Create(dbContext, account))
                {
                    try
                    {
                        var result = service.CreateFavoriteVendor(
                            account,
                            dto.VendorId,
                            dto.Notes);

                        return new CreateOperationResult()
                        {
                            Success = true,
                            Data = result
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
        [Route("FavoriteVendor/{favoriteVendorId:int}")]
        public OperationResult EditFavoriteVendor(Guid favoriteVendorId, FavoriteVendorDTO dto)
        {
            using (var dbContext = new GrowFlowContext())
            {
                using (var service = ComplianceService.Create(dbContext, account))
                {
                    try
                    {
                        var result = service.EditFavoriteVendor(
                            account,
                            dto.Id,
                            dto.VendorId,
                            dto.Notes);

                        return new CreateOperationResult()
                        {
                            Success = true,
                            Data = result
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

        [HttpDelete]
        [Route("Vendor/{favoriteVendorId:guid}")]
        public OperationResult DeleteVendor(int vendorId)
        {
            using (var dbContext = new GrowFlowContext())
            {
                using (var service = ComplianceService.Create(dbContext, account))
                {
                    try
                    {
                        var result = service.DeleteFavoriteVendor(account, vendorId);
                        return new CreateOperationResult()
                        {
                            Success = result
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